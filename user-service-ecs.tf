data "aws_ecs_task_definition" "user_service" {
  task_definition = "${aws_ecs_task_definition.user_service.family}"
  depends_on      = ["aws_ecs_task_definition.user_service"]
}

resource "aws_ecs_task_definition" "user_service" {
  family                   = "user-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.user_service_cpu}"
  memory                   = "${var.user_service_mem}"
  execution_role_arn       = "${aws_iam_role.cluster_execution_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.user_service_cpu},
    "environment" : [
        { 
            "name" : "SPRING_DATASOURCE_URL", 
            "value" : "jdbc:postgresql://${aws_db_instance.user_service_db.address}:${aws_db_instance.user_service_db.port}/${var.user_service_db_name}" 
        },
        {
            "name": "SPRING_DATASOURCE_USERNAME",
            "value": "${var.user_service_db_user}"
        },
        {
            "name": "SPRING_DATASOURCE_PASSWORD",
            "value": "${var.user_service_db_pass}"
        },
        {
          "name": "LINK_SERVICE_URL",
          "value": "${aws_alb.link_service_lb.dns_name}"
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
            "awslogs-stream-prefix": "user-service-logs"
        }
    },
    "image": "aleksanderbrzozowski/rso-user-service",
    "memory": ${var.user_service_mem},
    "networkMode": "awsvpc",
    "name": "user-service"
  }
]
DEFINITION
}

resource "aws_ecs_service" "user_service" {
  name            = "user-service"
  cluster         = "${aws_ecs_cluster.sshort_cluster.id}"
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.user_service.arn}"

  network_configuration {
    subnets          = ["${aws_subnet.public.*.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.main.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.user_service_lb_group.id}"
    container_name   = "user-service"
    container_port   = "8080"
  }

  depends_on = [
    "aws_alb_listener.gateway",
  ]
}
