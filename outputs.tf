output "workspace" {
  description = "The Terraform workspace used for this deployment."
  value       = terraform.workspace
}

output "vpc_id" {
  description = "Discovered default VPC ID."
  value       = data.aws_vpc.default.id
}

output "availability_zones" {
  description = "Available AZ names in the selected region."
  value       = data.aws_availability_zones.available.names
}

output "web_security_group_id" {
  description = "ID of the web-server security group."
  value       = aws_security_group.web.id
}

output "web_instance_ids" {
  description = "IDs of the created web-server instances."
  value       = aws_instance.web[*].id
}

output "web_instance_public_ips" {
  description = "Public IP addresses of the web-server instances, when assigned by the subnet."
  value       = aws_instance.web[*].public_ip
}
