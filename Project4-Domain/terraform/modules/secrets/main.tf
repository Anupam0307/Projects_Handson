resource "aws_secretsmanager_secret" "db" {
  name = "project4-db-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode(var.secret_values)
}
