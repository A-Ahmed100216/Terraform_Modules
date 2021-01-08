# Terraform Modules
* We can abstract complexity using Modules.
* We can separate code into separate files and then call these files in the main configuration file by directing to the location.
```hcl
module "app" {
  source = "./modules/app"
}
```
* Any variables which are used should also be defined.
```hcl
module "app" {
  source = "./modules/app"
  VPC-Aminah = aws_vpc.VPC-Aminah.id
  igw-Aminah = aws_internet_gateway.igw-Aminah.id
  app-ami = var.app_ami
  key-name = var.key_name
  db_public_ip = aws_instance.nodejs_instance-db.public_ip
}
```
## Variables
* Any variable referred to in the main.tf file should be stored in a variables file and defined as such:
```hcl
variable "sg_app_id" {}
```
* These variables can then be called in the main body with `var.name_of_variable`

### Outputs
* When we want to get information from a piece of infrastructure that will be abstracted in the modules, we can use outputs.
* The output keyword defines this parameter
* A description is optional
* Value refers to the resource, resource name and the parameter you wish to output.
```
output sg_app_id {
  description = "SG for app"
  value = aws_security_group.app_sg.id
}
```
