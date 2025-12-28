module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = "project4-eks-${var.environment}"
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # Access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # IRSA
  enable_irsa = true

  # Encryption (clean, managed by Terraform)
  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  # Let the module manage IAM (IMPORTANT)
  create_iam_role = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types

      desired_size = var.desired_size
      min_size     = var.min_size
      max_size     = var.max_size

      capacity_type               = "ON_DEMAND"
      associate_public_ip_address = false
    }
  }

  tags = {
    Environment = var.environment
    Project     = "project4"
  }
}
