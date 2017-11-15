variable "aws_region" {
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  default = "11.0.0.0/16"
}

variable "public_subnet_1a_cidr" {
  default = "11.0.1.0/16"
}

variable "public_subnet_1b_cidr" {
  default = "11.0.2.0/16"
}

variable "private_subnet_1a_cidr" {
  default = "11.0.3.0/16"
}

variable "private_subnet_1b_cidr" {
  default = "11.0.4.0/16"
}

variable "availability_zones" {
  default = ["ap-southeast-1a","ap-southeast-1b"]
}



variable "key_name" {
  default = "mywpkey"
}

variable "route53_zone" {
  default = "test.plivo"
}

variable "name_prefix" {
  default = "dl"
}


#
# AWS Es variables
#
variable "es_cluster_name" {
  default = "plivoes"
}

variable "cluster_vertical" {
  default = "plivo"
}

variable "es_cluster_role" {
  default = "logging"
}

variable "es_instance_count" {
  default = 3
}

# 
# Bastion variables
# 
variable "bastion_instance_type" {
  default = "t2.nano"
}

variable "bastion_ami" {
  default = "ami-e2cb878d"
}

# 
# Nginx Variables
# 
variable "nginx_instance_count" {
  default = 2
}
variable "nginx_instance_type" {
  default = "t2.nano"
}
variable "nginx_ami" {
  default = ["ami-efcb8780","ami-edcb8782"]
}

variable "es_proxy_ami" {
  default = "ami-eec28e81"
}

# 
# Logstash Variables
# 
variable "logstash_instance_count" {
  default = 1
}
variable "logstash_instance_type" {
  default = "t2.medium"
}
variable "logstash_ami" {
  default = "ami-e1cb878e"
}

# 
# Elasticsearch Variables
# 
variable "elasticsearch_instance_count" {
  default = 3
}
variable "elasticsearch_instance_type" {
  default = "t2.nano"
}
variable "elasticsearch_ami" {
  default = "ami-e0cb878f"
}

# 
# absystem Variables
# 
variable "absystem_instance_count" {
  default = 1
}
variable "absystem_instance_type" {
  default = "t2.medium"
}
variable "absystem_ami" {
  default = "ami-e3cb878c"
}

###
# Stage maintenance 
#
# terraform {
#   backend "s3" {
#     bucket = "tfplivo"
#     key    = "staging/service/pesmigration/terraform.tfstate"
#     region = "ap-south-1"
#   }
# }
