variable "ami_id" {
  description = "AMI ID built by Packer and used to launch EC2 instances"
  type        = string

  validation {
    condition     = can(regex("^ami-", var.ami_id))
    error_message = "ami_id must be a valid AMI ID starting with 'ami-'"
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}