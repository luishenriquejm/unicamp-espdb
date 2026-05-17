terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  # default = "sa-east-1"
  default = "eu-central-1"
}

locals {
  ami_map = {
    "sa-east-1"    = "ami-07a1d930e21d1450f" # Alma 9.7 sa-east-1
    "eu-central-1" = "ami-0934aa59c46d1ad3f" # Alma 9.7 eu-central-1
  }
}

provider "aws" {
  region = var.aws_region
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
  availability_zone       = "${var.aws_region}a"
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

  ingress {
    from_port   = 3389
    to_port     = 3389
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
  ami                    = local.ami_map[var.aws_region]
  instance_type          = "m8i.2xlarge"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = "aws-key-${var.aws_region}"
  availability_zone      = "${var.aws_region}a"
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.main.availability_zone
  type              = "gp3"
  size              = 150
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

