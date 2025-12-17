output "instance_01_public_ip" {
  description = "Public IP of EC2 instance 01"
  value       = aws_instance.instance_01.public_ip
}

output "instance_01_private_ip" {
  description = "Private IP of EC2 instance 01"
  value       = aws_instance.instance_01.private_ip
}

output "instance_02_private_ip" {
  description = "Private IP of EC2 instance 02"
  value       = aws_instance.instance_02.private_ip
}