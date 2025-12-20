helm delete vault  --namespace vault --wait --debug --kube-context $dc1
kubectl delete ns vault --context $dc1

kubectl config delete-cluster $dc1

terraform destroy -auto-approve