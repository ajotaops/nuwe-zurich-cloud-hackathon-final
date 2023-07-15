provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

##------------Variables Configuration------------##
locals {
  name      = "zurichhackathon-block2"
  cidr      = "10.60.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
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

  private_subnets     = [for k, az in local.azs : cidrsubnet(local.cidr, 8, k * 10 + 40)]
  private_subnet_names = [for az in local.azs : "${local.name}-private-${substr(az, -1, -1)}"]
  enable_nat_gateway = true

  public_subnets      = [for k, az in local.azs : cidrsubnet(local.cidr, 8, k * 10 + 10)]
  public_subnet_names = [for az in local.azs : "${local.name}-public-${substr(az, -1, -1)}"]

  map_public_ip_on_launch = true

  tags = local.tags
}
##-------------VPC------------##


##-------------IAM-ECS------------##
module "iam_ecs" {
    source = "./modules/iam/role"
    role = "role-ecs-${local.name}"
    statements = {
      "AssumeEcs" = {
        principals = {
          "Service" = ["ecs-tasks.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
        effect = "Allow"
      },
    }
}

resource "aws_iam_role_policy_attachment" "ecs_default" {
  role       = module.iam_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
##-------------IAM-ECS------------##


##-------------S3------------##
module "s3" {
    source = "./modules/s3"
    
    bucket_name = "bucket-${local.name}"

    public_access_block = {
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
    }

    statements = {
      "AllowReadOnly" = {
        principals = {
          "AWS" = [module.iam_ecs.arn]
        }
        actions = ["s3:*"]
        effect = "Allow"
      },
    }
}
##-------------S3------------##


##-------------ECS-CLUSTER------------##
resource "aws_cloudwatch_log_group" "default" {
  name = "log-group-ecs${local.name}"
}

resource "aws_ecs_cluster" "default" {
  name = "cluster-${local.name}"

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.default.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.default.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
##-------------ECS-CLUSTER------------##


##-------------ECS-TASK------------##
resource "aws_ecs_task_definition" "default" {
  family                   = "task-${local.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  task_role_arn            = module.iam_ecs.arn
  execution_role_arn       = module.iam_ecs.arn
  container_definitions = jsonencode([
      {
        name      = local.name
        image     = "docker.io/ajotaops/zurich-hackathon"
        cpu       = 512
        memory    = 1024
        essential = true
        portMappings = [
          {
            containerPort = 5000
            hostPort      = 5000
            protocol      = "tcp"
            appProtocol   = "http"
          }
        ]
        environment = [
          {
            name = "BUCKET_NAME",
            value = module.s3.id
          }
        ]
      },
    ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
##-------------ECS-TASK------------##


##-------------ECS-SG------------##
resource "aws_security_group" "default" {
  name        = "ecs-${local.name}"
  description = "Security Group for ECS task"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
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
##-------------ECS-SG------------##


##-------------ECS-ALB------------##
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"
  name = "alb-${local.name}"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.default.id]
  target_groups = [
    {
      name = "tg-${local.name}"
      backend_protocol = "HTTP"
      backend_port = 5000
      target_type = "ip"
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}
##-------------ECS-ALB------------##


##-------------ECS-SERVICE------------##
resource "aws_ecs_service" "default" {
  name            = "svc-${local.name}"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base = 1
    weight = 100
  }
  desired_count = 1

  network_configuration {
    subnets = module.vpc.private_subnets
    assign_public_ip = false
    security_groups = [aws_security_group.default.id]
  }

  load_balancer{
    target_group_arn = module.alb.target_group_arns[0]
    container_name = local.name
    container_port = 5000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
##-------------ECS-SERVICE------------##
