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

variable "route53_zone" {
  default = "test.plivo"
}

variable "name_prefix" {
  default = "dl"
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
  default = "ami-3c374c53"
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
  default = "ami-3c374c53"
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
  default = "ami-027c306d"
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
  default = "ami-3c374c53"
}

