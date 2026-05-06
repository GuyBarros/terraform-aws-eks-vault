data "aws_db_instance" "mysql" {
  db_instance_identifier = "${var.cluster_name}-mysql"
}


data "aws_db_instance" "postgres" {
  db_instance_identifier = "${var.cluster_name}-postgres"
}