output "instance_us_east_public_ip" {
  description = "Public IP of US-EAST-1 instance"
  value       = aws_instance.instance_east.public_ip
}

output "instance_east2_public_ip" {
  description = "Public IP of east2 instance"
  value       = aws_instance.instance_east2.public_ip
}

output "instance_us_east_private_ip" {
  description = "Private IP of US-EAST-1 instance"
  value       = aws_instance.instance_east.private_ip
}

output "instance_east2_private_ip" {
  description = "Private IP of east2 instance"
  value       = aws_instance.instance_east2.private_ip
}