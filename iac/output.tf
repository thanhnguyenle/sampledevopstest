output "instance_us_east_public_ip" {
  description = "Public IP of US-EAST-1 instance"
  value       = aws_instance.instance_east.public_ip
}

output "instance_singapore_public_ip" {
  description = "Public IP of Singapore instance"
  value       = aws_instance.instance_singapore.public_ip
}

output "instance_us_east_private_ip" {
  description = "Private IP of US-EAST-1 instance"
  value       = aws_instance.instance_east.private_ip
}

output "instance_singapore_private_ip" {
  description = "Private IP of Singapore instance"
  value       = aws_instance.instance_singapore.private_ip
}