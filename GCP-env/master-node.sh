#!/bin/bash

# 定義環境變數
ZONE="us-west4-a"              # 指定 Region
MASTER="master"                # master node 名稱
USER_HOME="/home/$(whoami)"    # 取得當前使用者的家目錄路徑

# 使用 gcloud compute ssh 命令遠端登入主節點，並執行以下操作：
# 1. 下載設定 node 所需的腳本 (1-setup-node.sh) 到使用者家目錄並執行
# 2. 下載設定 master node 所需的腳本 (2-master-node.sh) 到使用者家目錄並執行
gcloud compute ssh $MASTER --zone=$ZONE --command="wget -O $USER_HOME/1-setup-node.sh https://raw.githubusercontent.com/Jaspercyt/Kubernetes-1.31.1/main/GCP-env/GCE-shell/1-setup-node.sh && bash $USER_HOME/1-setup-node.sh"
gcloud compute ssh $MASTER --zone=$ZONE --command="wget -O $USER_HOME/2-master-node.sh https://raw.githubusercontent.com/Jaspercyt/Kubernetes-1.31.1/main/GCP-env/GCE-shell/2-master-node.sh && bash $USER_HOME/2-master-node.sh"

# 從 master node 複製 kubeadm 加入叢集所需的 token 到使用者的家目錄
gcloud compute scp $MASTER:$USER_HOME/kubeadm-token/kubeadm-join $USER_HOME --zone $ZONE

# 刪除家目錄中的安裝腳本和下載的檔案
# FILES_TO_REMOVE=(
#     "1-setup-node.sh"
#     "custom-resources.yaml"
#     "kubeadm-token"
#     "2-master-node.sh"
#     "etcd-v3.5.15-linux-amd64"
#     "kubectl-convert"
#     "cni-plugins-linux-amd64-v1.6.0.tgz"
#     "etcd-v3.5.15-linux-amd64.tar.gz"
#     "runc.amd64"
#     "containerd-1.7.23-linux-amd64.tar.gz"
#     "kubeadm-config.yaml"
# )

# CLEANUP_COMMAND="USER_HOME=\${USER_HOME:-~}; rm -rf"
# for file in "${FILES_TO_REMOVE[@]}"; do
#     CLEANUP_COMMAND+=" \$USER_HOME/$file"
# done

# gcloud compute ssh "$MASTER" --zone="$ZONE" --command="$CLEANUP_COMMAND"