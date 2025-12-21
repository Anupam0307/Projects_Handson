output "cluster_name" {
  value = module.eks.cluster_name
}

output "secret_name" {
  value = aws_secretsmanager_secret.db.name
}
