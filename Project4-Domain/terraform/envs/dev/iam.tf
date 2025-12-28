####################
# IAM Policy: Allow app to read DB secret
####################
resource "aws_iam_policy" "db_secret_access" {
  name = "project4-db-secret-access-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = module.db_secrets.secret_arn
      }
    ]
  })
}

####################
# Attach Policy to IRSA Role
####################
resource "aws_iam_role_policy_attachment" "db_secret_attach" {
  role       = module.irsa_app.role_name
  policy_arn = aws_iam_policy.db_secret_access.arn
}
