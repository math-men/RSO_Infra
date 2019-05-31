resource "cloudflare_record" "www" {
  domain = "${var.root_domain_name}"
  name   = "${var.www_domain_name}"
  value  = "${aws_alb.gateway.dns_name}"
  type   = "CNAME"
}

resource "cloudflare_record" "root" {
  domain = "${var.root_domain_name}"
  name   = "${var.root_domain_name}"
  value  = "${aws_alb.gateway.dns_name}"
  type   = "CNAME"
}
