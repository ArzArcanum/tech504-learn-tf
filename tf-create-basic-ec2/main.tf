terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.98.0"
    }
  }
}

# create an EC2 instance

# Where to create - set cloud provider
provider "aws" {
  region = var.my_region
}
# Get the default VPC
data "aws_vpc" "default"{
  id = "vpc-07e47e9d90d2076da"
}

# Create a security group resource
resource "aws_security_group" "app_security_group" {
  name        = "tech504-sam-tf-allow-port-22-3000-80"
  description = "Allow SSH from my IP and port 80(HTTP)&3000 from all"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH (port 22) only from your IP
  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Allow HTTP (port 80) from all
  ingress {
    description = "HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow port 3000 from all
  ingress {
    description = "Port 3000 from all"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_security_group"
  }
}

resource "aws_instance" "app_instance" {
  # Which AMI ID to use. ami-0c1c30571d2dae5c9 (for Ubuntu 22.04 LTS)
  ami = var.app_ami_id

  # Which instance type to use
  instance_type = var.my_instance_type
  
  # Add a public IP to this instance
  associate_public_ip_address = true

  # Add the security group
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  tags = {
    # Name of the instance
    Name = var.my_name,
    Environment = "test"
  }
}



# Syntax to HCL is {key = value}