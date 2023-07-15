provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

##------------Variables Configuration------------##
locals {
  name      = "zurichhackathon-block1"
  cidr      = "10.50.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
  ec2_names = ["one", "two"]
  tags = {
    Project = "Zurich Cloud Hackathon"
  }
}
##------------Variables Configuration------------##


##-------------VPC------------##
data "aws_availability_zones" "available" {}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.cidr

  azs                 = local.azs
  public_subnets      = [for k, az in local.azs : cidrsubnet(local.cidr, 8, k * 10 + 10)]
  public_subnet_names = [for az in local.azs : "${local.name}-${substr(az, -1, -1)}"]

  map_public_ip_on_launch = true

  tags = local.tags
}
##-------------VPC------------##


##-------------EC2------------##
resource "aws_security_group" "default" {
  name        = "${local.name}-sg"
  description = "Security Group for EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3035
    to_port     = 3035
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3035
    to_port     = 3035
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

module "keys" {
  source   = "terraform-aws-modules/key-pair/aws"
  for_each = toset(local.ec2_names)

  key_name           = "${local.name}-${each.key}"
  create_private_key = true
}

module "ec2_instances" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = toset(local.ec2_names)

  name = "${local.name}-${each.key}"

  instance_type          = "t2.micro"
  key_name               = "${local.name}-${each.key}"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = local.tags

  depends_on = [module.keys]
}
##-------------EC2-------------##