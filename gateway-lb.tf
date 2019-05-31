resource "aws_alb" "gateway" {
  name            = "sshort-gateway-lb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.main.id}"]
}

resource "aws_alb_target_group" "gateway_lb_group" {
  name        = "sshort-gateway-lb-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"
}

resource "aws_alb_target_group" "user_service_lb_group" {
  name        = "sshort-user-service-lb-target"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"

  health_check {
    path = "/health"
    matcher = "200-499"
    unhealthy_threshold = "10"
  }
}

resource "aws_alb_listener" "gateway" {
  load_balancer_arn = "${aws_alb.gateway.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
      host        = "${aws_alb.link_service_lb.dns_name}"
    }
  }
}

resource "aws_lb_listener_rule" "frontend_index" {
  listener_arn = "${aws_alb_listener.gateway.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.gateway_lb_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/"]
  }
}

resource "aws_lb_listener_rule" "frontend_static" {
  listener_arn = "${aws_alb_listener.gateway.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.gateway_lb_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/static/*"]
  }
}

resource "aws_lb_listener_rule" "frontend_favicon" {
  listener_arn = "${aws_alb_listener.gateway.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.gateway_lb_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/favicon.ico"]
  }
}

resource "aws_lb_listener_rule" "user_service_api" {
  listener_arn = "${aws_alb_listener.gateway.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.user_service_lb_group.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/api/*"]
  }
}
