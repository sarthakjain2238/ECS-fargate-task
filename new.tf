# Initialize the provider

provider "aws" {

  region = "ap-south-1"  # Specify the AWS region

}



# Define an Elastic IP for EC2

resource "aws_eip" "ec2_eip" {

instance = aws_instance.ec2_instance.id

}



# Launch EC2 Instance

resource "aws_instance" "ec2_instance" {

  ami           = "ami-0c55b159cbfafe1f0"  # Example Amazon Linux AMI, replace as needed

  instance_type = "t2.micro"

  

  # Configure EC2 Security Group to allow HTTP, HTTPS, and SSH access

security_groups = [aws_security_group.ec2_sg.name]



  # User data script to install ECS agent on EC2

  user_data = <<-EOF

    #!/bin/bash

echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config

  EOF

  

  tags = {

    Name = "ECS_EC2_Instance"

  }

}



# Define Security Group for EC2 instance

resource "aws_security_group" "ec2_sg" {

  name_prefix = "ecs_ec2_sg_"



  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  ingress {

    from_port   = 443

    to_port     = 443

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



# Create ECS Cluster

resource "aws_ecs_cluster" "ecs_cluster" {

  name = "my-ecs-cluster"

}



# Create Task Definition for ECS

resource "aws_ecs_task_definition" "ecs_task" {

  family                   = "my-task"

  network_mode             = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu                      = "256"

  memory                   = "512"



  container_definitions = <<DEFINITION

  [

    {

      "name": "nginx",

      "image": "nginx",

      "essential": true,

      "portMappings": [

        {

          "containerPort": 80,

          "hostPort": 80

        }

      ]

    }

  ]

  DEFINITION

}



# Attach Elastic IP to ECS Cluster's EC2 instance

resource "aws_eip" "ecs_eip" {

instance = aws_instance.ec2_instance.id

}



# ECS Service using Fargate Launch Type

resource "aws_ecs_service" "ecs_service" {

  name            = "my-ecs-service"

cluster = aws_ecs_cluster.ecs_cluster.id

  task_definition = aws_ecs_task_definition.ecs_task.arn

  launch_type     = "FARGATE"



  desired_count = 1



  network_configuration {

subnets = [aws_subnet.public_subnet.id]

security_groups = [aws_security_group.ecs_sg.id]

    assign_public_ip = true

  }

}



# Create a Public Subnet for ECS

resource "aws_subnet" "public_subnet" {

vpc_id = aws_vpc.main_vpc.id

cidr_block = "10.0.1.0/24"

  

  map_public_ip_on_launch = true

}



# Create a VPC for ECS Service

resource "aws_vpc" "main_vpc" {

cidr_block = "10.0.0.0/16"

}
