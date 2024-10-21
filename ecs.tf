resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "MyECSCluster"
}

resource "aws_ecs_service" "my_ecs_service" {
  name            = "MyService"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1

  launch_type = "EC2"
}

resource "aws_ecs_task_definition" "my_task_definition" {
  family = "my-task-family"

  container_definitions = jsonencode([
    {
      name  = "my-container"
      image = "nginx:latest"
      cpu   = 128
      memory = 128
      essential = true
    }
  ])
}
