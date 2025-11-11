provider "aws" {
    region = "ap-south-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_path {}

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

/*resource "aws_route_table" "myapp-route_table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet-l.id
    route_table_id = aws_route_table.myapp-route_table.id
}*/

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

#resource "aws_security_group" "myapp-sg" {
resource "aws_default_security_group" "default-sg" {
    #name = "${var.env_prefix}-sg"
    #description = "Allow HTTP and SSH inbound traffic"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080    
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = []
        prefix_list_ids = []
    }
    tags = {
       # Name = "${var.env_prefix}-sg"
        Name = "${var.env_prefix}-default-sg"
    }
}


data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"] # Canonical

    filter {
        name = "name"
        values = ["al2023-ami*-x86_64"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-aws_key_pair" {
    key_name = "${var.env_prefix}-keypair"
    public_key = file(var.public_key_path)
}

resource "aws_instance" "my_app_server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    subnet_id = aws_subnet.myapp-subnet-l.id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true

    user_data = <<EOF
                    #!/bin/bash
                    sudo yum update —y sudo yum install
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -p 8080:80 nginx
                EOF

    tags = {
        Name = "${var.env_prefix}-app-server"
    }
}