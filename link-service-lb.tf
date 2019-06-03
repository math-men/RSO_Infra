resource "aws_security_group" "link_service_lb" {
  name        = "sshort-link-service-lb-security-group"
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

resource "aws_alb" "link_service_lb" {
  name            = "sshort-link-service-lb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.link_service_lb.id}"]
}

resource "aws_alb_target_group" "link_service_lb_group" {
  name        = "sshort-link-service-lb-target"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"

  health_check {
    path = "/health"
  }
}

resource "aws_alb_listener" "link_service" {
  load_balancer_arn = "${aws_alb.link_service_lb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.link_service_lb_group.id}"
    type             = "forward"
  }
}
