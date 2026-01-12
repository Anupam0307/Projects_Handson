output "web_ip" {
  description = "Private IP of web EC2 instance"
  value       = aws_instance.web.private_ip
}
