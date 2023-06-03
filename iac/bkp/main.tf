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
    key    = "terraform.tfstate"
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


output "vpc_id" {
  value = aws_vpc.cloudbinary_vpc.id
}

