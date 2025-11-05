provider "aws" {
    region = "ap-south-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


resource "aws_subnet" "myapp-subnet-l" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

# resource "aws_vpc" "dev-vpc" {
#     cidr_block = "10.0.0.0/16"  
# }

# resource "aws_vpc" "dev-vpc-1" {
#     cidr_block = "10.0.0.0/24"
#     tags = {
#         Name: "dev-vpc-1-tag"
#     } 
# }

# output "aws_vpc_dev_id" {
#   value = aws_vpc.dev-vpc-1.cidr_block
# }

# resource "aws_subnet" "dev-subnet-1" {
#     vpc_id = aws_vpc.dev-vpc.id
#     cidr_block = "10.0.10.0/24"
#     availability_zone = "ap-south-1a"
# }

# data "aws_vpc" "existing_vpc" {
#     default = true
# }

# resource "aws_subnet" "dev-subnet-2" {
#     vpc_id = data.aws_vpc.existing_vpc.id
#     cidr_block = "172.31.48.0/20"
#     availability_zone = "ap-south-1a"
# }