# create an EC2 instance


# Where to create - provide cloud provider name
provider "aws" {
  # Which region to create the resource/service
  region = "eu-west-1"
}

# Which resource to create

resource "aws_instance" "app_instance" {
# Which AMI ID to use. ami-0c1c30571d2dae5c9 (for Ubuntu 22.04 LTS)
  ami = "ami-0c1c30571d2dae5c9"

  # which instance type to use
  instance_type = "t3.micro"
  
  # Add a public ip address to this instance
  associate_public_ip_address = true

  tags = {
    # Name of the instance
    Name = "tech504-sam-tf-test-app",
    Environment = "test"
  }
}
# aws_access_key = asdfasdf (MUST NEVER DO THIS)
# aws_secret_key = asdfasdf (MUST NEVER DO THIS)
# Syntax to HCL is {key = value}