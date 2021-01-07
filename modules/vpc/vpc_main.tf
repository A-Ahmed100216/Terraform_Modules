############# VPC ###############
resource "aws_vpc" "VPC-Aminah" {
    cidr_block = "13.0.0.0/16"
    instance_tenancy = "default"
    tags = {
        Name = "eng74-aminah-VPC-terraform"
    }
}

############# Internet Gateway ###############
resource "aws_internet_gateway" "igw-Aminah" {
    vpc_id = aws_vpc.VPC-Aminah.id
    tags = {
        Name = "eng74-aminah-igw-terraform"
    }
}
