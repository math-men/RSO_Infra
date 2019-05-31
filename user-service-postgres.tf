resource "aws_db_subnet_group" "user_service_db_subnet" {
  name       = "user-service-db-subnet"
  subnet_ids = ["${aws_subnet.public.*.id}"]
}

resource "aws_db_instance" "user_service_db" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "11.1"
  instance_class    = "db.t2.micro"
  name              = "${var.user_service_db_name}"
  username          = "${var.user_service_db_user}"
  password          = "${var.user_service_db_pass}"
  identifier        = "user-service-postgres"
  apply_immediately = "true"
  skip_final_snapshot = "true"
  db_subnet_group_name = "${aws_db_subnet_group.user_service_db_subnet.name}"
  vpc_security_group_ids = [["${aws_security_group.main.id}"]]
}
