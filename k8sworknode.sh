#!/bin/bash

#install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl enable docker.service
systemctl daemon-reload
systemctl restart docker.service
docker run hello-world

#enable and modify firewall
echo "y" | sudo ufw enable

ufw allow 6443/tcp
ufw allow 2379:2380/tcp
ufw allow 10250/tcp
ufw allow 10251/tcp
ufw allow 10252/tcp
ufw allow 10255/tcp
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#install kubernetes
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
# deb http://apt.kubernetes.io/ kubernetes-xenial main
# EOF

# use aliyun repository for CDC lab environment with gfw
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubeadm=1.21.0* kubelet=1.21.0* kubernetes-cni
systemctl enable kubelet
swapoff -a

# prepare the images accordingly, as from worknode to join master, also needs two images at least: pause and kube-proxy
docker pull louwy001/kube-apiserver:v1.21.0 && \
docker pull louwy001/kube-controller-manager:v1.21.0 && \
docker pull louwy001/kube-scheduler:v1.21.0 && \
docker pull louwy001/kube-proxy:v1.21.0 && \
docker pull louwy001/pause:3.4.1 && \
docker pull louwy001/etcd:3.4.13-0 && \
docker pull louwy001/coredns-coredns:v1.8.0 && \

docker tag louwy001/kube-apiserver:v1.21.0 k8s.gcr.io/kube-apiserver:v1.21.0 && \
docker tag louwy001/kube-controller-manager:v1.21.0 k8s.gcr.io/kube-controller-manager:v1.21.0 && \
docker tag louwy001/kube-scheduler:v1.21.0 k8s.gcr.io/kube-scheduler:v1.21.0 && \
docker tag louwy001/kube-proxy:v1.21.0 k8s.gcr.io/kube-proxy:v1.21.0 && \
docker tag louwy001/pause:3.4.1 k8s.gcr.io/pause:3.4.1 && \
docker tag louwy001/etcd:3.4.13-0 k8s.gcr.io/etcd:3.4.13-0 && \
docker tag louwy001/coredns-coredns:v1.8.0 k8s.gcr.io/coredns/coredns:v1.8.0 && \


docker rmi louwy001/kube-apiserver:v1.21.0 && \
docker rmi louwy001/kube-controller-manager:v1.21.0 && \
docker rmi louwy001/kube-scheduler:v1.21.0 && \
docker rmi louwy001/kube-proxy:v1.21.0 && \
docker rmi louwy001/pause:3.4.1 && \
docker rmi louwy001/etcd:3.4.13-0 && \
docker rmi louwy001/coredns-coredns:v1.8.0 && \

docker images



echo 'Enter kubeadm join command'