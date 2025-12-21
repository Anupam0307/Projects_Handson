#Bucket & DynamoDB must exist first

terraform {
  backend "s3" {
    bucket         = "anupam-terraform-states"
    key            = "project3/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
