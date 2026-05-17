terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "sa-east-1a"
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "main" {
  # ami                    = "ami-0145d8249c8d19b24" # Alma 10.1
  ami                    = "ami-079a0935c6776100d" # Alma 9.7
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = "aws-key-sa-east-1"
  availability_zone      = "sa-east-1a"
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.main.availability_zone
  type              = "gp3"
  size              = 50
  iops              = 3000
  throughput        = 125
  encrypted         = false
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}

output "public_ip" {
  value = aws_instance.main.public_ip
}
