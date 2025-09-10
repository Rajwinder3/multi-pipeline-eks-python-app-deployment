resource "aws_db_instance" "my-rds" {
  allocated_storage = 10
  db_name = "my-db"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  username = var.username
  password = var.password
  skip_final_snapshot = true
  db_subnet_group_name = var.private_subnet
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = var.security_group
  publicly_accessible = false
  storage_type = "gp2"

  tags = {
    Name = "RDS instance"
    }
}
