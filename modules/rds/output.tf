
output "rds_endpoint" {
  value = aws_db_instance.my-rds.endpoint
}

output "rds_instance_id" {
  value = aws_db_instance.my-rds.id
}
