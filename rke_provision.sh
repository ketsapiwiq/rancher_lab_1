vagrant up

## Source https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/kubernetes-rke/

# use cluster.yml by default
rke up

# Install cert manager
export KUBECONFIG=kube_config_cluster.yml

sleep 10

echo "Install the CustomResourceDefinition resources separately"
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

echo "Create the namespace for cert-manager"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
EOF

echo "Add the Jetstack Helm repository"
helm repo add jetstack https://charts.jetstack.io

echo "Update your local Helm chart repository cache"
helm repo update

echo "Install the cert-manager Helm chart"
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.12.0

echo "Waiting complete cert-manager deployment"
kubectl wait --for=condition=available deployment/cert-manager deployment/cert-manager-cainjector deployment/cert-manager-webhook -n cert-manager --timeout=60s

echo "Install Rancher"

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system
EOF

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher-lab.test


printf 'You should do (as super-user):\n echo "192.168.99.99 rancher-lab.test" >> /etc/hosts\n'

kubectl -n cattle-system rollout status deploy/rancher

echo 'You can now go to https://rancher-lab.test and set an admin password!'