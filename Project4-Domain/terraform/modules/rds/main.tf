resource "aws_db_subnet_group" "this" {
  name       = "project4-db-subnet-${var.environment}"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "this" {
  name   = "project4-db-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier        = "project4-db-${var.environment}"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  skip_final_snapshot = true
  publicly_accessible = false
}
