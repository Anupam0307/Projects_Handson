provider "aws" {
  region = "us-east-1"
}

####################
# VPC
####################
module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway = true
}

####################
# NACL (Private)
####################
module "nacl" {
  source          = "../../modules/nacl"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

####################
# EKS
####################
module "eks" {
  source = "../../modules/eks"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # MUST be free-tier eligible
  node_instance_types = var.node_instance_types

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
}

####################
# Secrets Manager (DB)
####################
module "db_secrets" {
  source = "../../modules/secrets"

  environment = var.environment

  # Terraform sends these once; AWS stores encrypted at rest
  secret_values = {
    username = "postgres"
    password = "postgres123"
  }
}

####################
# Read DB Secret (explicit dependency)
####################
data "aws_secretsmanager_secret_version" "db" {
  secret_id = module.db_secrets.secret_arn

  # IMPORTANT: avoid eventual consistency failure
  depends_on = [
    module.db_secrets
  ]
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.db.secret_string
  )
}

####################
# RDS
####################
module "rds" {
  source = "../../modules/rds"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  db_username = local.db_creds.username
  db_password = local.db_creds.password
}

####################
# IRSA (App)
####################
module "irsa_app" {
  source = "../../modules/iam-irsa"

  role_name = "project4-app-irsa-${var.environment}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.environment}:app-sa"]
    }
  }
}