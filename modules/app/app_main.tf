############# Public Subnet ###############
resource "aws_subnet" "subnet_public" {
    vpc_id = var.VPC-Aminah
    cidr_block = "13.0.1.0/24"
    tags = {
        Name = "eng74-aminah-public-subnet-terraform"
    }
}

############# NACL Public ###############
resource "aws_network_acl" "nacl" {
  vpc_id = var.VPC-Aminah
  subnet_ids=[aws_subnet.subnet_public.id]

  egress {
    protocol   = "all"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Port 80 open for all
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Port 443 open for all
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Port 22 open for my ip
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${var.my_ip}/32"
    from_port  = 22
    to_port    = 22
  }

  # Ephemeral ports open for all
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "eng74-aminah-public-nacl-terraform"
  }
}


############# Public Route Table ###############
resource "aws_route_table" "route_table" {
  vpc_id =  var.VPC-Aminah

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw-Aminah
  }

  tags = {
    Name = "eng74-aminah-public-route-terraform"
  }
}

############# Public Route Table Association ###############
resource "aws_route_table_association" "route_table" {
  route_table_id= aws_route_table.route_table.id
  subnet_id=aws_subnet.subnet_public.id
}


############# Security Group for App ###############
resource "aws_security_group" "app_sg" {
  name        = "eng74-aminah-app-sg-public"
  description = "Allows traffic to app"
  vpc_id      = var.VPC-Aminah

  ingress {
    description = "All http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https traffic"
    from_port   = 443
    to_port     = 443
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
    Name = "eng74-aminah-app-sg"
  }
}

############# App EC2 Instance ###############
resource "aws_instance" "nodejs_instance-app" {
    ami = var.app-ami
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id=aws_subnet.subnet_public.id
    security_groups=[aws_security_group.app_sg.id]
    tags = {
        Name = "eng74-aminah-nodejs-app-3"
    }
    key_name = var.key-name
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/eng74-aminah-aws-key.pem")}"
      host = "${self.public_ip}"
    }
    provisioner "remote-exec" {
      inline = [ "cd app/","DB_HOST=${var.db_public_ip} pm2 start app.js"]
    }
}
