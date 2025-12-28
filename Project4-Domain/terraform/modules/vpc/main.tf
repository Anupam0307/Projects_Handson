module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "project4-vpc-${var.environment}"
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Project     = "project4"
    Environment = var.environment
  }
}
