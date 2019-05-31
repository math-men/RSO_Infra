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

variable "ecs_log_group" {
  default = "sshort-cluster-logs"
}

variable "frontend_cpu" {
  default = "256"
}

variable "frontend_mem" {
  default = "512"
}

variable "link_service_cpu" {
  default = "256"
}

variable "link_service_mem" {
  default = "512"
}

variable "user_service_cpu" {
  default = "256"
}

variable "user_service_mem" {
  default = "512"
}

variable "user_service_db_name" {
  default = "userservicedb"
}

variable "user_service_db_user" {
  default = "userserviceuser"
}

variable "user_service_db_pass" {
}

