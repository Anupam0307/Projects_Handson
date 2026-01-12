packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

source "amazon-ebs" "base_ami" {
  region        = "ap-south-1"
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"
  ami_name      = "devops-base-ami-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
}

build {
  sources = ["source.amazon-ebs.base_ami"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker git nginx",
      "sudo systemctl enable docker nginx"
    ]
  }
}
