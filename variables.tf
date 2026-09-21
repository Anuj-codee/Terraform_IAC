variable "project_name" {
  description = "Short project name used in resource names and tags."
  type        = string
  default     = "terraform-web"
}

variable "environment" {
  description = "Deployment environment. It must match the selected Terraform workspace."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either dev or prod."
  }
}

variable "region" {
  description = "AWS region in which to discover and create resources."
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for the web servers."
  type        = string
}

variable "instance_count" {
  description = "Number of web-server EC2 instances to create."
  type        = number

  validation {
    condition     = var.instance_count > 0
    error_message = "Instance count must be at least one."
  }
}

variable "allowed_ssh_cidr" {
  description = "IPv4 CIDR allowed to SSH to the web servers; replace the documentation CIDR with your public IP/32 before deployment."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid IPv4 CIDR, for example 203.0.113.10/32."
  }
}
