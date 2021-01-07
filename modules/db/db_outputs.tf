output db_ip {
  description = "Public ip for DB_HOST"
  value = aws_instance.nodejs_instance-db.public_ip
}
