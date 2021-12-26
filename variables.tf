variable "region" {
  
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
  description = "nginx instance"
}

variable "env" {
  type = string
  description = "environment in which to deploy"
}

variable "tags" {
  type = map(string)
  default = {}
  description = "tag to set on instance"
}