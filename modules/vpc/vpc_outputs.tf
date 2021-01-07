output vpc_id {
  description = "VPC ID"
  value = aws_vpc.VPC-Aminah.id
}

output igw_id {
  description = "Internet gateway ID"
  value = aws_internet_gateway.igw-Aminah.id
}
