
provider "aws" {
  region = "us-west-1"
}

# Reuse the existing default VPC and its two public subnets.
data "aws_vpc" "training" {
  id = "vpc-0c5d83b3e8de99de9"
}

data "aws_subnet" "public_a" {
  id = "subnet-0d8395f5f4021e7a5"
}

data "aws_subnet" "public_b" {
  id = "subnet-06bf27c1c88b2386c"
}

locals {
  image_uri = "661255175149.dkr.ecr.us-west-1.amazonaws.com/property-api:latest"
}

# Security group for the public PropertyLite API.
resource "aws_security_group" "property_api" {
  name        = "week9-property-api-sg"
  description = "Temporary public access to PropertyLite on port 8080"
  vpc_id      = data.aws_vpc.training.id

  ingress {
    description = "PropertyLite API lab access"
    from_port   = 8080
    to_port     = 8080
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

# IAM role that lets ECS pull from ECR and send logs to CloudWatch.
resource "aws_iam_role" "ecs_execution" {
  name = "week9-property-api-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch log group for container logs.
resource "aws_cloudwatch_log_group" "property_api" {
  name              = "/ecs/week9-property-api"
  retention_in_days = 1
}

# ECS cluster.
resource "aws_ecs_cluster" "property_api" {
  name = "week9-propertylite-cluster"
}

# Fargate task definition.
resource "aws_ecs_task_definition" "property_api" {
  family                   = "week9-property-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "property-api"
      image     = local.image_uri
      essential = true

      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.property_api.name
          "awslogs-region"        = "us-west-1"
          "awslogs-stream-prefix" = "property-api"
        }
      }
    }
  ])
}

# Run one Fargate task in the existing public subnets.
resource "aws_ecs_service" "property_api" {
  name            = "week9-property-api-service"
  cluster         = aws_ecs_cluster.property_api.id
  task_definition = aws_ecs_task_definition.property_api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      data.aws_subnet.public_a.id,
      data.aws_subnet.public_b.id
    ]

    security_groups  = [aws_security_group.property_api.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution
  ]
}

output "cluster_name" {
  value = aws_ecs_cluster.property_api.name
}

output "service_name" {
  value = aws_ecs_service.property_api.name
}

output "security_group_id" {
  value = aws_security_group.property_api.id
}

output "image_uri" {
  value = local.image_uri
}

