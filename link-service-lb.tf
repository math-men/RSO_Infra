resource "aws_alb" "link_service_lb" {
  name            = "sshort-link-service-lb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.main.id}"]
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
