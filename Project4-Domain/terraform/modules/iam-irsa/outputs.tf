output "role_name" {
  description = "IAM role name created for IRSA"
  value       = module.this.iam_role_name
}
