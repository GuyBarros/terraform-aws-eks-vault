

module "secondary" {
  # I'd have to remove all the provider from the modules, not today
  # for_each = toset(var.cluster_names)
  source = "./modules"

  aws_region         = var.secondary_region
  cluster_name = var.secondary_cluster_name
  vault_license = var.vault_license
  cluster_version = var.cluster_version
  vault_namespace = var.vault_namespace
  
}

output "secondary_region" {
  description = "AWS region of the secondary vault cluster"
  value       = var.secondary_region
}

output "secondary_vault_cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.secondary.cluster_name
}

output "secondary_vault_access_instructions" {
  description = "Instructions for accessing Vault with TLS"
  value       = <<-EOT
    1. Add the Vault Kubernetes cluster to your kubeconfig:
       aws eks update-kubeconfig --region ${var.secondary_region} --name ${var.secondary_cluster_name}

    2. Check that all vault servers are running:
       kubectl get pods -n ${var.vault_namespace}

    3. Initialize Vault (only once):
       kubectl exec -n vault vault-0 -- vault operator init \
        -recovery-shares=7 \
        -recovery-threshold=4 \
        -format=json > ./secondary-cluster-keys.json

    4. Get the Vault LoadBalancer address:
       echo https://$(kubectl get svc vault-ui -n vault -o json | jq -r ".status.loadBalancer.ingress[0].hostname"):8200

    
    5. Save the CA certificate to a file:
       terraform output -raw vault_ca_cert > vault-ca.crt
    
    6. Set environment variables:
       export VAULT_ADDR=https://<LOADBALANCER_ADDRESS>:8200
       export VAULT_CACERT=vault-ca.crt
    
     
    
    6. Or access via kubectl port-forward:
       kubectl port-forward -n ${var.vault_namespace} vault-0 8200:8200
       export VAULT_ADDR=https://127.0.0.1:8200
       export VAULT_CACERT=vault-ca.crt
  EOT
}