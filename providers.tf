provider "aws" {
  region  = "us-east-1"
  version = "~> 2.9"
}

provider "cloudflare" {
  email = "olek.brzozowski@gmail.com"
  token = "${var.cloudflare_token}"
  version = "~> 1.13"
}