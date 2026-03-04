variable "access_key" {
  sensitive = true
}
variable "secret_access_key" {
  sensitive = true
}
variable "cidr_all_ipv4" {
  default = "0.0.0.0/0"
}
variable "ubuntu_ami" {
  type    = string
  default = "ami-019715e0d74f695be"
}
variable "key_pair_name" {
  description = "existing ssh key-pair name"
  type        = string
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "frontend_image" {
  type    = string
  default = "025380047428.dkr.ecr.ap-south-1.amazonaws.com/flask-app/frontend:latest"
}
variable "backend_image" {
  type    = string
  default = "025380047428.dkr.ecr.ap-south-1.amazonaws.com/flask-app/backend:latest"
}

