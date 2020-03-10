
# ssh -i .vagrant/machines/ranchouille/virtualbox/private_key vagrant@192.168.1.100

## Source https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/kubernetes-rke/

rke up # use cluster.yml by default

# Install cert manager

alias kc='kubectl --kubeconfig kube_config_cluster.yml'
alias helm='helm --kubeconfig kube_config_cluster.yml'

sleep 10

## Install the CustomResourceDefinition resources separately
kc apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

## Create the namespace for cert-manager
kc create namespace cert-manager

## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

## Update your local Helm chart repository cache
helm repo update

## Install the cert-manager Helm chart
helm install \
  cert-manager jetstack/cert-manager \
  --namesace cert-manager \
  --version v0.12.0

sleep 60

# Install Rancher

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kc create namespace cattle-system
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org

kc -n cattle-system rollout status deploy/rancher