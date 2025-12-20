
# Outputs
# output "cluster_endpoint" {
#   description = "Endpoint for EKS control plane"
#   value       = module.eks.cluster_endpoint
# }

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# output "cluster_security_group_id" {
#   description = "Security group ID attached to the EKS cluster"
#   value       = module.eks.cluster_security_group_id
# }

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

# output "configure_kubectl" {
#   description = "Configure kubectl"
#   value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
# }

# output "vault_kms_key_id" {
#   description = "KMS Key ID for Vault auto-unseal"
#   value       = aws_kms_key.vault.id
# }

# output "vault_service_account_role_arn" {
#   description = "IAM Role ARN for Vault service account"
#   value       = module.vault_irsa.iam_role_arn
# }

# output "vault_ui_address" {
#   description = "Get Vault UI LoadBalancer address with: kubectl get svc vault-ui -n vault"
#   value       = "kubectl get svc vault-ui -n ${var.vault_namespace}"
# }

# output "vault_init_command" {
#   description = "Initialize Vault after deployment"
#   value       = "kubectl exec -n ${var.vault_namespace} vault-0 -- vault operator init"
# }

# output "vault_ca_cert" {
#   description = "Vault CA certificate for client verification"
#   value       = tls_self_signed_cert.vault_ca.cert_pem
#   sensitive   = true
# }

output "vault_access_instructions" {
  description = "Instructions for accessing Vault with TLS"
  value       = <<-EOT
    1. Add the Vault Kubernetes cluster to your kubeconfig:
       aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}

    2. Check that all vault servers are running:
       kubectl get pods -n ${var.vault_namespace}

    3. Initialize Vault (only once):
       kubectl exec -n vault vault-0 -- vault operator init \
        -recovery-shares=7 \
        -recovery-threshold=4 \
        -format=json > ./cluster-keys.json

    4. Get the Vault LoadBalancer address:
       kubectl get svc vault-ui -n ${var.vault_namespace}
    
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