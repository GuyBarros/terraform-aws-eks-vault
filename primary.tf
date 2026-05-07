

module "primary" {
  # I'd have to remove all the provider from the modules, not today
  # for_each = toset(var.cluster_names)
  source = "./modules"

  aws_region         = var.primary_region
  cluster_name = var.primary_cluster_name
  vault_license = var.vault_license
  cluster_version = var.cluster_version
  vault_namespace = var.vault_namespace
  public_key = var.public_key
  
  is_hashicorp = true
}

output "primary_region" {
  description = "AWS region of the primary vault cluster"
  value       = var.primary_region
}

output "primary_vault_cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.primary.cluster_name
}


output "primary_vault_access_instructions" {
  description = "Instructions for accessing Vault with TLS"
  value       = <<-EOT
    1. Add the Vault Kubernetes cluster to your kubeconfig:
       aws eks update-kubeconfig --region ${var.primary_region} --name ${var.primary_cluster_name}

    2. Check that all vault servers are running:
       kubectl get pods -n ${var.vault_namespace}

    3. Initialize Vault (only once):
       kubectl exec -n vault vault-0 -- vault operator init \
        -recovery-shares=7 \
        -recovery-threshold=4 \
        -format=json > ./primary-cluster-keys.json

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