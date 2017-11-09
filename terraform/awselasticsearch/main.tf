provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_elasticsearch_domain" "elasticsearch" {
    domain_name = "${var.cluster_vertical}-${var.cluster_app}"
    elasticsearch_version = "5.5"
    cluster_config {
        instance_type = "c4.large.elasticsearch"
    }
    instance_count= "${var.aws_es_instance_count}"
    ebs_options {
        ebs_enabled = true,
        volume_type = "standard",
        volume_size = 50
    }
    advanced_options {
        "rest.action.multi.allow_explicit_index" = "true"
    }

    access_policies = <<CONFIG
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["119.82.125.220", "123.201.135.20"]}
            }
        }
    ]
    }
    CONFIG

    snapshot_options {
        automated_snapshot_start_hour = 23
    }

    tags {
        "Name" = "${var.cluster_vertical}-${var.cluster_app}"
        "Vertical" = "${var.cluster_vertical}"
        "App" ="${var.cluster_app}"
        "Role" = "${var.cluster_role}"
        "Cluster" = "${var.cluster_vertical}-${var.cluster_app}"
    }
}

terraform {
  backend "s3" {
    bucket = "tfplivo"
    key    = "staging/service/awselasticsearch/terraform.tfstate"
    region = "ap-south-1"
  }
}