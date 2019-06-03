data "aws_ecs_task_definition" "link_service" {
  task_definition = "${aws_ecs_task_definition.link_service.family}"
  depends_on      = ["aws_ecs_task_definition.link_service"]
}

resource "aws_ecs_task_definition" "link_service" {
  family                   = "link-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.link_service_cpu}"
  memory                   = "${var.link_service_mem}"
  execution_role_arn       = "${aws_iam_role.cluster_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.link_service_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.link_service_cpu},
    "environment" : [
        { 
            "name" : "PORT", 
            "value" : "8080" 
        },
        {
            "name": "REGION",
            "value": "us-east-1"
        },
        {
          "name": "ISLOCAL",
          "value": "false"
        }
    ],
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.ecs_log_group}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "link-service-logs"
        }
    },
    "image": "aleksanderbrzozowski/rso-link-service",
    "memory": ${var.link_service_mem},
    "networkMode": "awsvpc",
    "name": "link-service"
  }
]
DEFINITION
}

resource "aws_security_group" "link_service" {
  name        = "sshort-link-service-security-group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
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

resource "aws_ecs_service" "link_service" {
  name            = "link-service"
  cluster         = "${aws_ecs_cluster.sshort_cluster.id}"
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.link_service.arn}"

  network_configuration {
    subnets          = ["${aws_subnet.public.*.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.link_service.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.link_service_lb_group.id}"
    container_name   = "link-service"
    container_port   = "8080"
  }

  depends_on = [
    "aws_alb_listener.link_service",
  ]
}
