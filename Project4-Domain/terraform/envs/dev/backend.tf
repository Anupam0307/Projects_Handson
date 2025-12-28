terraform {
  backend "s3" {
    bucket         = "anupam-terraform-states"
    key            = "project4/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
