variable "aws_region" {
  default = "ap-south-1"
}

variable "es_cluster_name" {
  default = "plivoes"
}

variable "cluster_vertical" {
  default = "plivo"
}

variable "es_cluster_role" {
  default = "logging"
}

variable "bastion_instance_type" {
  default = "t2.medium"
}

variable "bastion_ami" {
  default = "ami-3c374c53"
}

variable "key_name" {
  default = "mywpkey"
}

