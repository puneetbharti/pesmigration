# The provider here is aws but it can be other provider
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "plivo_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "PlivoVPC"
  }
}

# Create a way out to the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.plivo_vpc.id}"
  tags {
        Name = "InternetGateway"
    }
}

# Public route as way out to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.plivo_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
#   tags {
#         Name = "Public route table"
#   }
}


# Create the private route table
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.plivo_vpc.id}"

    tags {
        Name = "Private route table"
    }
}

# Create private route
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

# Create a subnet in the AZ ap-south-1a
resource "aws_subnet" "subnet_ap_south_1a" {
  vpc_id                  = "${aws_vpc.plivo_vpc.id}"
  cidr_block              = "11.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
  	Name =  "Subnet az 1a"
  }
}

# Create a subnet in the AZ ap-south-1b
resource "aws_subnet" "subnet_ap_south_1b" {
  vpc_id                  = "${aws_vpc.plivo_vpc.id}"
  cidr_block              = "11.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
  	Name =  "Subnet az 1b"
  }
}

# Create an EIP for the natgateway
resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}


# Create a nat gateway and it will depend on the internet gateway creation
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.subnet_ap_south_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

# Associate subnet subnet_ap_south_1a to public route table
resource "aws_route_table_association" "subnet_ap_south_1a_association" {
    subnet_id = "${aws_subnet.subnet_ap_south_1a.id}"
    route_table_id = "${aws_vpc.plivo_vpc.main_route_table_id}"
}

# Associate subnet subnet_ap_south_1b to private route table
resource "aws_route_table_association" "subnet_ap_south_1b_association" {
    subnet_id = "${aws_subnet.subnet_ap_south_1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

# route 53 zone 
resource "aws_route53_zone" "plivo_zone" {
  name   = "test.plivo"
  vpc_id = "${aws_vpc.plivo_vpc.id}"
}

# Security Groups for Elasticsearch Domain
resource "aws_security_group" "aws_es_sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "aws_es_sg"
  }
}


# AWS ElasticSearch Domain
resource "aws_elasticsearch_domain" "elasticsearch" {
    domain_name = "${var.es_cluster_name}"
    elasticsearch_version = "5.5"
    cluster_config {
        instance_type = "c4.large.elasticsearch"
        instance_count= "${var.es_instance_count}"
    }
    
    ebs_options {
        ebs_enabled = true,
        volume_type = "standard",
        volume_size = 50
    }
    vpc_options {
        security_group_ids = ["${aws_security_group.aws_es_sg.id}"]
        subnet_ids = ["${aws_subnet.subnet_ap_south_1a.id}"]
    }
    advanced_options {
        "rest.action.multi.allow_explicit_index" = "true"
    }

    depends_on = ["aws_internet_gateway.gw", "aws_route_table_association.subnet_ap_south_1a_association"]

    # access_policies = <<CONFIG
    # {
    # "Version": "2012-10-17",
    # "Statement": [
    #     {
    #         "Action": "es:*",
    #         "Principal": "*",
    #         "Effect": "Allow"
    #     }
    # ]
    # }
    # CONFIG

    snapshot_options {
        automated_snapshot_start_hour = 23
    }

    tags {
        "Name" = "${var.es_cluster_name}"
        "Role" = "${var.es_cluster_role}"
    }
}

##  Es domain route 53 
# resource "aws_route53_record" "es_domain" {
#   count= 1
#   zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
#   name = "plivodashboard"
#   type = "A"
#   #ttl = "3"
#   alias {
#     name                   = "${aws_elasticsearch_domain.elasticsearch.domain_name}"
#     zone_id                = "${aws_elasticsearch_domain.elasticsearch.zone_id}"
#     evaluate_target_health = true
#   }
# }

##
# Bastion
##

# bastion security group 
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "bastion_sg"
  }
}

# elastic ip for bastion host
resource "aws_eip" "bastion" {
  vpc      = true
  depends_on = ["aws_elasticsearch_domain.elasticsearch"]
}

# setting up jump box/bastion host 
resource "aws_instance" "bastion" {

  instance_type = "${var.bastion_instance_type}"

  ami = "${var.bastion_ami}"

  key_name = "${var.key_name}"

  count= 1

  subnet_id = "${aws_subnet.subnet_ap_south_1a.id}"

  vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]

  depends_on = ["aws_elasticsearch_domain.elasticsearch", "aws_eip.bastion"]

  tags {
    "Name" = "bastion.${var.route53_zone}"
    "Role" = "gateway"
  }
}

# elasticip association 
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion.id}"
}
# setting reoute 53 zone for bastion 
resource "aws_route53_record" "bastion" {
  count = 1
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "bastion"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.bastion.*.public_ip, count.index)}"]
  depends_on = ["aws_eip_association.bastion_eip_assoc"]
}
