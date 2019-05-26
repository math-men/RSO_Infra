resource "aws_ecs_cluster" "sshort_cluster" {
  name = "sshort-cluster"
}

data "aws_ecs_task_definition" "nginx" {
  task_definition = "${aws_ecs_task_definition.nginx.family}"
  depends_on      = ["aws_ecs_task_definition.nginx"]
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = <<DEFINITION
[
  {
    "cpu": 256,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "image": "nginx",
    "memory": 512,
    "networkMode": "awsvpc",
    "name": "nginx"
  }
]
DEFINITION
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "${aws_ecs_cluster.sshort_cluster.id}"
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.nginx.arn}"

  network_configuration {
    subnets          = ["${aws_subnet.public.*.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.main.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "nginx"
    container_port   = "80"
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}
