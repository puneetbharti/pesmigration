##
# logstash
##

# logstash Security Group
resource "aws_security_group" "logstash_sg" {
  name        = "logstash_sg"
  description = "logstash security group"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
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
    Name = "logstash_sg"
  }
}

#logstash instances
resource "aws_instance" "logstash" {

  instance_type = "${var.logstash_instance_type}"

  ami = "${var.logstash_ami}"

  key_name = "${var.key_name}"

  count= "${var.logstash_instance_count}"

  subnet_id = "${aws_subnet.subnet_ap_south_1b.id}"

  vpc_security_group_ids = ["${aws_security_group.logstash_sg.id}"]

  tags {
    "Name" = "${format("${var.name_prefix}${var.cluster_vertical}logstash%02d.${var.route53_zone}", count.index + 1)}"
    "Vertical" = "${var.cluster_vertical}"
    "App" ="logstash"
    "Role" = "proxy"
    "Cluster" = "logstash-proxy"
  }
}

# logstash Route 53 for logstash 
resource "aws_route53_record" "logstash" {
  count= "${var.logstash_instance_count}"
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "${format("${var.name_prefix}${var.cluster_vertical}logstash%02d", count.index + 1)}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.logstash.*.private_ip, count.index)}"]
}