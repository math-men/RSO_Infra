resource "aws_s3_bucket" "www" {
  bucket = "${var.www_domain_name}"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.www_domain_name}/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket" "redirect" {
  bucket = "${var.root_domain_name}"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.root_domain_name}/*"]
    }
  ]
}
POLICY

  website {
    redirect_all_requests_to = "${var.www_domain_name}"
  }
}
resource "cloudflare_record" "www" {
  domain = "${var.root_domain_name}"
  name   = "${var.www_domain_name}"
  value  = "${aws_s3_bucket.www.website_endpoint}"
  type   = "CNAME"
}

resource "cloudflare_record" "root" {
  domain = "${var.root_domain_name}"
  name   = "${var.root_domain_name}"
  value  = "${aws_s3_bucket.redirect.website_endpoint}"
  type   = "CNAME"
}