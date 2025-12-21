resource "aws_secretsmanager_secret" "db" {
  name = "project3-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "appuser"
    password = random_password.db.result
  })
}

resource "random_password" "db" {
  length  = 16
  special = true
}
