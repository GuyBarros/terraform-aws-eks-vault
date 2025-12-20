#!/bin/bash
#script to set up Vault with TLS on EKS, mostly copied from here: https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-tls#install-the-vault-helm-chart
# Update kubeconfig after deploying each EKS cluster
#DC1
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

#Kubectl get clusters
kubectl config get-clusters

# update these variables every deploy
export dc1=arn:aws:eks:us-west-2:958215610051:cluster/claude2

# DC1
kubectl config use-context $dc1

#Export the working directory location and the naming variables.
export VAULT_K8S_CONTEXT=$dc1 \
export VAULT_K8S_NAMESPACE="vault" \
export VAULT_HELM_RELEASE_NAME="vault" \
export VAULT_SERVICE_NAME="vault" \
export K8S_CLUSTER_NAME="cluster.local" \
export WORKDIR="/Users/guybarros/GIT_ROOT/terraform-aws-eks-vault" 


kubectl -n $VAULT_K8S_NAMESPACE get pods

kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault operator init \
    -recovery-shares=7 \
    -recovery-threshold=4 \
    -format=json > ./cluster-keys.json


#Create a variable named VAULT_UNSEAL_KEY to capture the Vault unseal key.
VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" ${WORKDIR}/cluster-keys.json)

#Unseal Vault running on the vault-0 pod.
kubectl exec -n $VAULT_K8S_NAMESPACE vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
