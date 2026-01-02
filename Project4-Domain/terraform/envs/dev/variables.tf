variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "node_instance_types" {
  description = "EKS node instance types"
  type        = list(string)
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "aws_region" {
  description = "AWS region for EKS and ALB controller"
  type        = string
  default     = "us-east-1"
}