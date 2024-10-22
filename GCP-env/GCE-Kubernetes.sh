#!/bin/bash

# 下載並執行 cloud-shell.sh 腳本
wget https://raw.githubusercontent.com/Jaspercyt/Kubernetes-1.31.1/main/GCP-env/cloud-shell.sh -O cloud-shell.sh
bash cloud-shell.sh

# 下載並執行 master-node.sh 腳本
wget https://raw.githubusercontent.com/Jaspercyt/Kubernetes-1.31.1/main/GCP-env/master-node.sh -O master-node.sh
bash master-node.sh

# 下載並執行 worker-node.sh 腳本
wget https://raw.githubusercontent.com/Jaspercyt/Kubernetes-1.31.1/main/GCP-env/worker-node.sh -O worker-node.sh
bash worker-node.sh

# (可選) 刪除下載的腳本檔案
# rm -rf GCE-Kubernetes.sh cloud-shell.sh master-node.sh worker-node.sh 1-setup-node.sh 2-master-node.sh kubeadm-join