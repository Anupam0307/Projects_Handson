provider "aws" {
  region = "us-east-1"
}

####################
# VPC
####################
module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  cidr               = "10.1.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.11.0/24", "10.1.12.0/24"]
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

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets

  node_instance_types = ["t3.micro"]
  desired_size   = 1
  min_size       = 1
  max_size       = 1
}

####################
# Secrets Manager (DB)
####################
module "db_secrets" {
  source = "../../modules/secrets"

  environment = var.environment

  secret_values = {
    username = "postgres"
    password = "change-me-prod"
  }
}

####################
# RDS
####################

data "aws_secretsmanager_secret_version" "db" {
  secret_id = module.db_secrets.secret_arn
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}


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

  role_name = "project4-app-irsa-prod"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["prod:app-sa"]
    }
  }

  policy_arn = module.db_secrets.secret_arn
}

####################
# Route53
####################
module "route53" {
  source      = "../../modules/route53"
  domain_name = "anupamghai.shop"
}
