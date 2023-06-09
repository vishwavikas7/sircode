# Versions 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}
# Authentication to AWS from Terraform code
provider "aws" {
  region  = "us-east-1"
  #profile = "default"
}

terraform {
  backend "s3" {
    bucket = "codewithck.com"
    key    = "dev/terraform.state"
    region = "us-east-1"
  }
}


# Create a VPC in AWS part of region i.e. Mumbai 
resource "aws_vpc" "cloudbinary_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name       = "cloudbinary_vpc"
    Created_By = "Terraform"
  }
}

# Create a Public-Subnet1 part of cloudbinary_vpc 
resource "aws_subnet" "cloudbinary_public_subnet1" {
  vpc_id                  = aws_vpc.cloudbinary_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name       = "cloudbinary_public_subnet1"
    created_by = "Terraform"
  }
}
resource "aws_subnet" "cloudbinary_public_subnet2" {
  vpc_id                  = aws_vpc.cloudbinary_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name       = "cloudbinary_public_subnet2"
    created_by = "Terraform"
  }
}

resource "aws_subnet" "cloudbinary_private_subnet1" {
  vpc_id            = aws_vpc.cloudbinary_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name       = "cloudbinary_private_subnet1"
    created_by = "Terraform"
  }
}
resource "aws_subnet" "cloudbinary_private_subnet2" {
  vpc_id            = aws_vpc.cloudbinary_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name       = "cloudbinary_private_subnet2"
    created_by = "Terraform"
  }
}

# IGW
resource "aws_internet_gateway" "cloudbinary_igw" {
  vpc_id = aws_vpc.cloudbinary_vpc.id

  tags = {
    Name       = "cloudbinary_igw"
    Created_By = "Terraform"
  }
}

# RTB
resource "aws_route_table" "cloudbinary_rtb_public" {
  vpc_id = aws_vpc.cloudbinary_vpc.id

  tags = {
    Name       = "cloudbinary_rtb_public"
    Created_By = "Teerraform"
  }
}
resource "aws_route_table" "cloudbinary_rtb_private" {
  vpc_id = aws_vpc.cloudbinary_vpc.id

  tags = {
    Name       = "cloudbinary_rtb_private"
    Created_By = "Teerraform"
  }
}

# Create the internet Access 
resource "aws_route" "cloudbinary_rtb_igw" {
  route_table_id         = aws_route_table.cloudbinary_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloudbinary_igw.id

}

resource "aws_route_table_association" "cloudbinary_subnet_association1" {
  subnet_id      = aws_subnet.cloudbinary_public_subnet1.id
  route_table_id = aws_route_table.cloudbinary_rtb_public.id
}
resource "aws_route_table_association" "cloudbinary_subnet_association2" {
  subnet_id      = aws_subnet.cloudbinary_public_subnet2.id
  route_table_id = aws_route_table.cloudbinary_rtb_public.id
}
resource "aws_route_table_association" "cloudbinary_subnet_association3" {
  subnet_id      = aws_subnet.cloudbinary_private_subnet1.id
  route_table_id = aws_route_table.cloudbinary_rtb_private.id
}
resource "aws_route_table_association" "cloudbinary_subnet_association4" {
  subnet_id      = aws_subnet.cloudbinary_private_subnet2.id
  route_table_id = aws_route_table.cloudbinary_rtb_private.id
}

# Elastic Ipaddress for NAT Gateway
resource "aws_eip" "cloudbinary_eip" {
  vpc = true
}

# Create Nat Gateway 
resource "aws_nat_gateway" "cloudbinary_gw" {
  allocation_id = aws_eip.cloudbinary_eip.id
  subnet_id     = aws_subnet.cloudbinary_public_subnet1.id

  tags = {
    Name      = "Nat Gateway"
    Createdby = "Terraform"
  }
}

# Allow internet access from NAT Gateway to Private Route Table
resource "aws_route" "cloudbinary_rtb_private_gw" {
  route_table_id         = aws_route_table.cloudbinary_rtb_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.cloudbinary_gw.id
}

# Network Access Control List 
resource "aws_network_acl" "cloudbinary_nsg" {
  vpc_id = aws_vpc.cloudbinary_vpc.id
  subnet_ids = [
    "${aws_subnet.cloudbinary_public_subnet1.id}",
    "${aws_subnet.cloudbinary_public_subnet2.id}",
    "${aws_subnet.cloudbinary_private_subnet1.id}",
    "${aws_subnet.cloudbinary_private_subnet2.id}"
  ]

  # All ingress port 22 
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  # Allow ingress of port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  # Allow ingress of port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }
  # Allow ingress of ports from 1024 to 65535
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow egress of port 22
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  # Allow egress of port 80
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  # Allow egress of port 80
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }
  # Allow egress of ports from 1024 to 65535
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name      = "cloudbinary_nsg"
    createdby = "Terraform"
  }
}

# EC2 instance Security group
resource "aws_security_group" "cloudbinary_sg_bastion" {
  vpc_id      = aws_vpc.cloudbinary_vpc.id
  name        = "sg_cloudbinary_ssh_rdp"
  description = "To Allow SSH From IPV4 Devices"

  # Allow Ingress / inbound Of port 22 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 8080 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudbinary_sg_bastion"
    Description = "cloudbinary allow SSH - RDP"
    createdby   = "terraform"
  }

}

# EC2 instance Security group
resource "aws_security_group" "cloudbinary_sg" {
  vpc_id      = aws_vpc.cloudbinary_vpc.id
  name        = "sg_cloudbinary_ssh"
  description = "To Allow SSH From IPV4 Devices"

  # Allow Ingress / inbound Of port 22 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 80 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 8080 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudbinary_sg"
    Description = "cloudbinary allow SSH - HTTP and Jenkins"
    createdby   = "terraform"
  }

}

# Bastion - Windows 
resource "aws_instance" "cloudbinary_bastion" {
  ami                    = "ami-0d86c69530d0a048e"
  instance_type          = "t2.micro"
  key_name               = "cb_nv_9am"
  subnet_id              = aws_subnet.cloudbinary_public_subnet1.id
  vpc_security_group_ids = ["${aws_security_group.cloudbinary_sg_bastion.id}"]
  tags = {
    Name      = "cloudbinary_Bastion"
    CreatedBy = "Terraform"
  }
}

# WebServer - Private Subnet 
resource "aws_instance" "cloudbinary_web" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "cb_nv_9am"
  subnet_id              = aws_subnet.cloudbinary_private_subnet1.id
  vpc_security_group_ids = ["${aws_security_group.cloudbinary_sg.id}"]
  user_data              = file("web.sh")
  tags = {
    Name      = "cloudbinary_webserver"
    CreatedBy = "Terraform"
  }
}

output "vpc_id" {
  value = aws_vpc.cloudbinary_vpc.id
}
