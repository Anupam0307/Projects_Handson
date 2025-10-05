variable "aws_region" {
  type    = string
  default = "us-east-1" # CloudFront uses global but ACM cert for CloudFront must be in us-east-1 if using a regional cert
}

variable "domain_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}
