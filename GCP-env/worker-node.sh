#!/bin/bash

# 定義環境變數
ZONE="us-west4-a"                               # 指定區域
SETUP_SCRIPT_URL="https://raw.githubusercontent.com/Jaspercyt/Kubernetes-1.31.1/main/GCP-env/GCE-shell/1-setup-node.sh" # 設定節點的腳本 URL
NODE_IPS=("192.168.56.11" "192.168.56.12")      # worker node 的 IP 陣列
KUBEADM_JOIN_FILE="kubeadm-join"                # kubeadm-join 腳本

# 定義 setup_node 函式
setup_node() {
  local node=$1  # 參數1: 節點名稱
  local ip=$2    # 參數2: 節點 IP 地址

  # 1. 下載並執行節點設置腳本
  echo "正在設定節點 $node..."
  gcloud compute ssh $node --zone=$ZONE --command="wget -q --show-progress -O /home/$USER/1-setup-node.sh $SETUP_SCRIPT_URL && bash /home/$USER/1-setup-node.sh"
  if [ $? -ne 0 ]; then
    echo "錯誤：無法下載或執行 $node 上的 1-setup-node.sh 腳本"
    exit 1
  fi

  # 2. 確認本地 kubeadm-join 檔案存在
  if [ ! -f "$KUBEADM_JOIN_FILE" ]; then
    echo "錯誤：找不到 kubeadm-join 檔案，請確保該檔案存在於本地目錄。"
    exit 1
  fi

  # 3. 複製 kubeadm-join 腳本到節點
  gcloud compute scp $KUBEADM_JOIN_FILE $node:/home/$USER/ --zone=$ZONE
  if [ $? -ne 0 ]; then
    echo "錯誤：無法將 kubeadm-join 檔案複製到 $node"
    exit 1
  fi

  # 4. 設置 kubeadm-join 的執行權限並執行加入 Kubernetes 叢集
  gcloud compute ssh $node --zone=$ZONE --command="chmod +x /home/$USER/kubeadm-join && sudo sh /home/$USER/kubeadm-join"
  if [ $? -ne 0 ]; then
    echo "錯誤：無法在 $node 上執行 kubeadm-join"
    exit 1
  fi

  # 5. 修改 kubelet 的啟動參數，設置節點 IP 並重啟 kubelet
  gcloud compute ssh $node --zone=$ZONE --command="sudo sed -i 'a KUBELET_EXTRA_ARGS=\"--node-ip=$ip\"' /var/lib/kubelet/kubeadm-flags.env && sudo systemctl daemon-reload && sudo systemctl restart kubelet"
  if [ $? -ne 0 ]; then
    echo "錯誤：無法在 $node 上修改 kubelet 配置或重啟 kubelet"
    exit 1
  fi

  # 6. 清理安裝過程中產生的臨時檔案
  gcloud compute ssh $node --zone=$ZONE --command="rm -rf /home/$USER/1-setup-node.sh /home/$USER/cni-plugins-linux-amd64-v1.6.0.tgz /home/$USER/containerd-1.7.23-linux-amd64.tar.gz /home/$USER/kubeadm-join /home/$USER/runc.amd64"
  if [ $? -ne 0 ]; then
    echo "警告：無法在 $node 上清理臨時檔案"
  else
    echo "$node 設定完成並成功清理臨時檔案。"
  fi
}

# 迴圈讀取 NODE_IPS 陣列，對每個 worker node 調用 setup_node 函式進行設定
for i in ${!NODE_IPS[@]}; do
  setup_node "worker0$((i+1))" "${NODE_IPS[$i]}"
done