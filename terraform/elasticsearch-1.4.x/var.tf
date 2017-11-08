//
// tags
// this is going to be used for tagging purpose
//

variable "num_instances" {
  default = 3
}

variable "name_prefix" {
  default = "dl"
}

variable "cluster_app" {
  default = "elasticsearch"
}

variable "cluster_vertical" {
  default = "plivo"
}

variable "cluster_role" {
  default = "logging"
}



variable "instance_type" {
  default = "t2.nano"
}

variable "base_ami" {
  default = "ami-3c374c53"
}

variable "key_name" {
  default = "mywpkey"
}

variable "security_groups" {
  default = ["sg-0c45da64", "sg-165b0e7e"]
}

//
// End of tags
//



variable "aws_region" {
  default = "ap-south-1"
}

//
// route 53 zones
variable "route53_zone" {
  default = "topmkt.net"
}

variable "route53_zone_id" {
  default = "Z3UP578CWT5IM1"
}
// End of route 53
//

// subnets
// we devide the number of instances into two subnet groups
// so we are configuring two subnets

variable "subnets" {
  default = ["subnet-823dd0eb","subnet-823dd0eb"]
}
