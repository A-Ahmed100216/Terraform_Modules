output sg_app_id {
  description = "SG for app"
  value = aws_security_group.app_sg.id
}

output public_subnet_ip {
  description = "Public subnet IP"
  value = aws_subnet.subnet_public.cidr_block
}

output public_subnet_id {
  description = "ID of public subnet"
  value = aws_subnet.subnet_public.id
}
