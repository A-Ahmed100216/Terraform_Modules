
############# Private Subnet ###############
resource "aws_subnet" "subnet_private" {
    vpc_id = var.VPC-Aminah
    cidr_block = "13.0.2.0/24"
    tags = {
        Name = "eng74-aminah-private-subnet-terraform"
    }
}

############# SECURITY GROUP FOR DB ###############
resource "aws_security_group" "db-sg-terraform" {
  name        = "eng74-aminah-db-sg"
  description = "Allow specified traffic for db"
  vpc_id      = var.VPC-Aminah

  ingress {
    description = "port 27017"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    # security_groups = [var.sg_app_id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 80 open"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng74-aminah-db-sg"
  }
}


############# NACL Private ###############
resource "aws_network_acl" "nacl_priv" {
  vpc_id = var.VPC-Aminah
  subnet_ids=[aws_subnet.subnet_private.id]
  # subnet_ids = [public_subnet_id]

  egress {
    protocol   = "all"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.public_subnet_ip
    # cidr_block = "13.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${var.my_ip}/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    # cidr_block = var.public_subnet_ip
    cidr_block = "0.0.0.0/0"
    from_port  = 27017
    to_port    = 27017
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "eng74-aminah-private-nacl-terraform"
  }
}


############# Private Route Table ###############
resource "aws_route_table" "route_table_priv" {
  vpc_id =  var.VPC-Aminah

  tags = {
    Name = "eng74-aminah-private-route-terraform"
  }
}



############# Private Route Table Association ###############
resource "aws_route_table_association" "private_route_table" {
  route_table_id= aws_route_table.route_table_priv.id
  subnet_id=aws_subnet.subnet_private.id
}


############# Db EC2 Instance ###############
resource "aws_instance" "nodejs_instance-db" {
    ami = var.db-ami
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
        Name = "eng74-aminah-nodejs-db-2"
    }
    key_name = var.key-name
    subnet_id=var.public_subnet_id
    vpc_security_group_ids=[aws_security_group.db-sg-terraform.id]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/eng74-aminah-aws-key.pem")}"
      host = "${self.public_ip}"
    }
    provisioner "remote-exec" {
      inline = [ "sudo systemctl start mongod" ]
    }
}
