provider "aws" {
  region = var.region
}

# ------------------------
# VPC (Simple & Minimal)
# ------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
}

# ------------------------
# EKS Cluster
# ------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::802732540071:user/devops-07"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # ------------------------
  # Managed Node Group
  # ------------------------
  eks_managed_node_groups = {
    default = {
      name = "learning-eks-workers"

      desired_size = 2
      min_size     = 2
      max_size     = 2

      instance_types = [var.node_instance_type]

      tags = {
        Name        = "learning-eks-worker"
        Environment = "dev"
        Project     = "eks-helm-learning"
      }

      labels = {
        role = "worker"
        app  = "general"
      }
    }
  }
}
