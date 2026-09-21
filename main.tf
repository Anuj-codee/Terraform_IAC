locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Discover the account's default VPC rather than embedding a VPC ID.
data "aws_vpc" "default" {
  default = true
}

# Discover subnets in that VPC. The first available subnet is used for this
# small demonstration deployment; production systems should normally spread
# instances across explicitly selected private subnets.
data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Amazon Linux 2023, resolved at plan time so no AMI ID is hardcoded.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Web and limited SSH access for ${local.name_prefix}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from the administrator network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Required outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
  })

  lifecycle {
    precondition {
      condition     = terraform.workspace == var.environment
      error_message = "Select the ${var.environment} workspace before planning or applying this environment."
    }
  }
}

resource "aws_instance" "web" {
  count = var.instance_count

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = sort(tolist(data.aws_subnets.default_vpc.ids))[0]
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    echo "<h1>${var.project_name} - ${var.environment} web server ${count.index + 1}</h1>" > /var/www/html/index.html
    systemctl enable --now httpd
  EOF

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-${count.index + 1}"
  })

  lifecycle {
    precondition {
      condition     = length(data.aws_subnets.default_vpc.ids) > 0
      error_message = "The default VPC has no subnets in ${var.region}. Create a subnet or select a region with a default VPC."
    }
  }
}
