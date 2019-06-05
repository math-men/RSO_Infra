data "aws_ecs_task_definition" "frontend" {
  task_definition = "${aws_ecs_task_definition.frontend.family}"
  depends_on      = ["aws_ecs_task_definition.frontend"]
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.frontend_cpu}"
  memory                   = "${var.frontend_mem}"
  execution_role_arn       = "${aws_iam_role.cluster_execution_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.frontend_cpu},
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.ecs_log_group}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "frontend-logs"
        }
    },
    "image": "aleksanderbrzozowski/rso-frontend",
    "memory": ${var.frontend_mem},
    "networkMode": "awsvpc",
    "name": "frontend"
  }
]
DEFINITION
}

resource "aws_security_group" "frontend" {
  name        = "sshort-frontend-security-group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = "${aws_ecs_cluster.sshort_cluster.id}"
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.frontend.arn}"

  network_configuration {
    subnets          = ["${aws_subnet.public.*.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.frontend.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.gateway_lb_group.id}"
    container_name   = "frontend"
    container_port   = "80"
  }

  depends_on = [
    "aws_alb_listener.gateway",
  ]
}
