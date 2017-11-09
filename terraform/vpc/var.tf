variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "11.0.0.0/16"
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
# Bastion variables
# 
variable "bastion_instance_type" {
  default = "t2.medium"
}

variable "bastion_ami" {
  default = "ami-f87a3697"
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
  default = ["ami-9d7438f2","ami-08773b67"]
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
  default = "ami-ff753990"
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
  default = "ami-e0773b8f"
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
  default = "ami-f87a3697"
}

