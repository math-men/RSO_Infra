resource "aws_ecs_cluster" "sshort_cluster" {
  name = "sshort-cluster"
}

resource "aws_cloudwatch_log_group" "sshort_cluster_logs" {
  name = "${var.ecs_log_group}"
}
