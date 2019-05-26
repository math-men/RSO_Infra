variable "www_domain_name" {
  description = "WWW domain name"
  default     = "www.sshort.me"
}

variable "root_domain_name" {
  description = "Domain root name"
  default     = "sshort.me"
}

variable "cloudflare_token" {
  description = "Cloudflare token"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}
