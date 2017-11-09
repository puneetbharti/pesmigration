##
# elasticsearch
##

# elasticsearch Security Group
resource "aws_security_group" "elasticsearch_sg" {
  name        = "elasticsearch_sg"
  description = "elasticsearch security group"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    self        = true
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

  depends_on = ["aws_security_group.bastion_sg"]

  tags {
    Name = "elasticsearch_sg"
  }
}

#elasticsearch instances
resource "aws_instance" "elasticsearch" {

  instance_type = "${var.elasticsearch_instance_type}"

  ami = "${var.elasticsearch_ami}"

  key_name = "${var.key_name}"

  count= "${var.elasticsearch_instance_count}"

  subnet_id = "${aws_subnet.subnet_ap_south_1b.id}"

  vpc_security_group_ids = ["${aws_security_group.elasticsearch_sg.id}"]

  tags {
    "Name" = "${format("${var.name_prefix}${var.cluster_vertical}elasticsearch%02d.${var.route53_zone}", count.index + 1)}"
    "Vertical" = "${var.cluster_vertical}"
    "App" ="elasticsearch"
    "Role" = "logsearch"
    "Version" ="1.4.2"
    "Cluster" = "elasticsearch-logsearch"
  }
}

# elasticsearch Route 53 for elasticsearch 
resource "aws_route53_record" "elasticsearch" {
  count= "${var.elasticsearch_instance_count}"
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "${format("${var.name_prefix}${var.cluster_vertical}elasticsearch%02d", count.index + 1)}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.elasticsearch.*.private_ip, count.index)}"]
}