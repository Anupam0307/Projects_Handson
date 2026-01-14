resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type           = "t3.micro"
  associate_public_ip_address = true

  tags = {
    Name = "web-server"
    Role = "web"
  }
}

