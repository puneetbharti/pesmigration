###
## AWS Elasticsearch domain 
#
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

     access_policies = <<CONFIG
     {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Action": "es:*",
             "Principal": "*",
             "Effect": "Allow"
         }
     ]
     }
     CONFIG

    snapshot_options {
        automated_snapshot_start_hour = 23
    }

    tags {
        "Name" = "${var.es_cluster_name}"
        "Role" = "${var.es_cluster_role}"
    }
}

##  Es domain route 53 
resource "aws_route53_record" "es_domain" {
  count= 1
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "esdomain"
  type = "CNAME"
  ttl = "3"
  records = ["${aws_elasticsearch_domain.elasticsearch.endpoint}"]
}

## setting slow logs and cloudwatch 
resource "null_resource" "aws_es" {
  provisioner "local-exec" {
    command = "python es_logs.py ${aws_cloudwatch_log_group.aws_es_log_group.arn}"
  }
}
