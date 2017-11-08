provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_instance" "elasticsearch" {

  instance_type = "${var.instance_type}"

  ami = "${var.base_ami}"

  key_name = "${var.key_name}"

  count= "${var.num_instances}"

  subnet_id = "${var.subnets[count.index%2]}"

  vpc_security_group_ids = "${var.security_groups}"

  root_block_device {
    volume_type = "standard"
    volume_size = 50
  }

  monitoring = true

  tags {
    "Name" = "${format("${var.name_prefix}${var.cluster_vertical}es%02d.${var.route53_zone}", count.index + 1)}"
    "Vertical" = "${var.cluster_vertical}"
    "App" ="${var.cluster_app}"
    "Role" = "${var.cluster_role}"
    "Cluster" = "${var.cluster_vertical}-${var.cluster_app}"
  }
}

resource "aws_route53_record" "elasticsearch" {
  count = "${var.num_instances}"
  zone_id = "${var.route53_zone_id}"
  name = "${format("${var.name_prefix}${var.cluster_vertical}es%02d", count.index + 1)}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.elasticsearch.*.public_ip, count.index)}"]
}

resource "null_resource" "inventory_base" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.elasticsearch.*.id)}"
  }
  triggers {
    cluster_instance_ids = "${join(",", aws_route53_record.elasticsearch.*.id)}"
  }
  provisioner "local-exec" {
    command = "echo '[local]\n localhost\n [all:vars]\n ansible_ssh_user=ubuntu \n ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem \n [${var.cluster_vertical}]' > ${path.module}/../../ansible/inventories/${var.cluster_vertical}_${var.cluster_app}.ini"
  }
}

resource "null_resource" "inventory" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.elasticsearch.*.id)}"
  }
  triggers {
    cluster_instance_ids = "${join(",", aws_route53_record.elasticsearch.*.id)}"
  }
  triggers {
    cluster_instance_ids = "${join(",", null_resource.inventory_base.*.id)}"
  }
  count = "${var.num_instances}"

  
  provisioner "local-exec" {
    command = "echo ${format("${var.name_prefix}${var.cluster_vertical}es%02d.${var.route53_zone}", count.index + 1)} >> ${path.module}/../../ansible/inventories/${var.cluster_vertical}_${var.cluster_app}.ini"
  }
}

resource "null_resource" "elasticsearch" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.elasticsearch.*.id)}"
  }
  triggers {
    cluster_instance_ids = "${join(",", aws_route53_record.elasticsearch.*.id)}"
  }
  
  triggers {
    cluster_instance_ids = "${join(",", null_resource.inventory_base.*.id)}"
  }

  triggers {
    cluster_instance_ids = "${join(",", null_resource.inventory.*.id)}"
  }

   provisioner "local-exec" {
    command = "cd ${path.module}/../../ansible/ && ansible-playbook -e 'ANSIBLE_HOST_KEY_CHECKING=False' -i inventories/${var.cluster_vertical}_${var.cluster_app}.ini elasticsearch.yml --extra-vars='hosts=${var.cluster_vertical} vertical_name=${var.cluster_vertical}'"
  }
}



terraform {
  backend "s3" {
    bucket = "tfplivo"
    key    = "staging/service/elasticsearch1.4.x/terraform.tfstate"
    region = "ap-south-1"
  }
}