#!/bin/bash
#script to set up Vault with TLS on EKS, mostly copied from here: https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-tls#install-the-vault-helm-chart
# Update kubeconfig after deploying each EKS cluster
#DC1
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name_cluster1)

#Kubectl get clusters
kubectl config get-clusters

# update these variables every deploy
export dc1=arn:aws:eks:eu-west-2:958215610051:cluster/cluster1-7TW5OS1m

# DC1
kubectl config use-context $dc1

#Export the working directory location and the naming variables.
export VAULT_K8S_CONTEXT=$dc1 \
export VAULT_K8S_NAMESPACE="vault" \
export VAULT_HELM_RELEASE_NAME="vault" \
export VAULT_SERVICE_NAME="vault" \
export K8S_CLUSTER_NAME="cluster.local" \
export WORKDIR="/Users/guybarros/GIT_ROOT/terraform-aws-eks-vault" 
# export VAULT_AUTO_UNSEAL_ADDR="https://do-not-delete-ever-v2-public-vault-cf6a1d76.5773df81.z1.hashicorp.cloud:8200" \
# export VAULT_AUTO_UNSEAL_NAMESPACE="admin" \
# export VAULT_AUTO_UNSEAL_TOKEN=$(vault token create -orphan -policy="autounseal"  -period=24h   -field=token)



#Create Vault Namespace
kubectl create ns $VAULT_K8S_NAMESPACE --context $VAULT_K8S_CONTEXT

#Create the consul ent license k8s secret
kubectl create secret generic vault-ent-license --namespace vault --from-file=license=/Users/guybarros/Hashicorp/vault.hclic

#Generate the private key
openssl genrsa -out ${WORKDIR}/vault.key 2048

#Create the CSR configuration file
 cat > ${WORKDIR}/vault-csr.conf <<EOF
[req]
default_bits = 2048
prompt = no
encrypt_key = yes
default_md = sha256
distinguished_name = kubelet_serving
req_extensions = v3_req
[ kubelet_serving ]
O = system:nodes
CN = system:node:*.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.${VAULT_SERVICE_NAME}
DNS.2 = *.${VAULT_SERVICE_NAME}.${VAULT_K8S_NAMESPACE}.svc.${K8S_CLUSTER_NAME}
DNS.3 = *.${VAULT_K8S_NAMESPACE}
IP.1 = 127.0.0.1
EOF

#Generate the CSR
openssl req -new -key ${WORKDIR}/vault.key -out ${WORKDIR}/vault.csr -config ${WORKDIR}/vault-csr.conf

#Create the csr yaml file to send it to Kubernetes.
cat > ${WORKDIR}/csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
   name: vault.svc
spec:
   signerName: kubernetes.io/kubelet-serving
   expirationSeconds: 8640000
   request: $(cat ${WORKDIR}/vault.csr|base64|tr -d '\n')
   usages:
   - digital signature
   - key encipherment
   - server auth
EOF

#deploy CSR to Kubernetes
kubectl create -f ${WORKDIR}/csr.yaml

#Approve the CSR in Kubernetes.
kubectl certificate approve vault.svc

#Confirm the certificate was issued
kubectl get csr vault.svc

#Retrieve the certificate
kubectl get csr vault.svc -o jsonpath='{.status.certificate}' | openssl base64 -d -A -out ${WORKDIR}/vault.crt

#Retrieve Kubernetes CA certificate
kubectl config view \
--raw \
--minify \
--flatten \
-o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
| base64 -d > ${WORKDIR}/vault.ca

#Create the TLS secret
kubectl create secret generic vault-ha-tls \
   -n $VAULT_K8S_NAMESPACE \
   --from-file=vault.key=${WORKDIR}/vault.key \
   --from-file=vault.crt=${WORKDIR}/vault.crt \
   --from-file=vault.ca=${WORKDIR}/vault.ca

#Create the Vault auto unseal secret
# kubectl delete secret vault-transit-autounseal -n $VAULT_K8S_NAMESPACE
# kubectl create secret generic vault-transit-autounseal \
#    -n $VAULT_K8S_NAMESPACE \
#    --from-literal=VAULT_ADDR=${VAULT_AUTO_UNSEAL_ADDR} \
#    --from-literal=VAULT_TOKEN=${VAULT_AUTO_UNSEAL_TOKEN} \
#    --from-literal=VAULT_NAMESPACE=${VAULT_AUTO_UNSEAL_NAMESPACE} 
# kubectl delete secret vault-transit-autounseal -n $VAULT_K8S_NAMESPACE

#If needed install the Vault Helm chart repository
# helm repo add hashicorp https://helm.releases.hashicorp.com
# helm repo update
# helm install vault hashicorp/vault

#Install Vault using the helm vaules file
#check the installation with --dry-run first
helm install -n $VAULT_K8S_NAMESPACE $VAULT_HELM_RELEASE_NAME hashicorp/vault -f ${WORKDIR}/vault_kms_autounseal.yaml --wait --debug --kube-context $VAULT_K8S_CONTEXT --dry-run
#Then run the actual install
helm install -n $VAULT_K8S_NAMESPACE $VAULT_HELM_RELEASE_NAME hashicorp/vault -f ${WORKDIR}/vault_kms_autounseal.yaml --wait --debug --kube-context $VAULT_K8S_CONTEXT
#Check Pods
kubectl -n $VAULT_K8S_NAMESPACE get pods


kubectl exec -n vault vault-0 -- vault operator init \
    -recovery-shares=7 \
    -recovery-threshold=4 \
    -format=json > ./cluster-keys.json


