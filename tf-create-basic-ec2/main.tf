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
}
# Get the default VPC
data "aws_vpc" "default"{
  id = "vpc-07e47e9d90d2076da"
}

resource "aws_security_group" "app_security_group" {
  name        = "tech504-sam-tf-app-sg"
  description = "Allow SSH from my IP and port 80(HTTP)&3000 from all"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH (port 22) only from your IP
  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

    # Allow egress from all
  egress {
    description = "Egress on all ports to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_security_group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "tech504-sam-tf-db-sg"
  description = "Allow inbound SSH and MongoDB access from app-instances, and outbound my IP and port 80(HTTP)&3000 from all"
  vpc_id      = data.aws_vpc.default.id

  # Allow port 3000 from all
  ingress {
    description = "Port 3000 from all"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }
  # Allow egress from all
  egress {
    description = "Egress on all ports to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_security_group"
  }

resource "aws_instance" "app_instance" {

  # Which OS to use
  ami = "ami-0c1c30571d2dae5c9" # Ubuntu 22.04 LTS

  instance_type = "t3.micro"

  key_name = "tech504-sam-aws-key"
  # Add a public IP to this instance
  associate_public_ip_address = true

  # Add the security group
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  tags = {
    # Name of the instance
    Name = "tech504-sam-app-node",
    # This is an ansible target node
    Ansible = "target"
  }
}

resource "aws_instance" "db_instance" {

  # Which OS to use
  ami = "ami-0c1c30571d2dae5c9" # Ubuntu 22.04 LTS

  instance_type = "t3.micro"

  key_name = "tech504-sam-aws-key"
  # Add a public IP to this instance
  associate_public_ip_address = true

  # Add the security group
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  tags = {
    # Name of the instance
    Name = "tech504-sam-db-node",
    # This is an ansible target node
    Ansible = "target"
  }
}
