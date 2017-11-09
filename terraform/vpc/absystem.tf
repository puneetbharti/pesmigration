##
# absystem
##

# absystem Security Group
resource "aws_security_group" "absystem_sg" {
  name        = "absystem_sg"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "absystem_sg"
  }
}

#absystem instances
resource "aws_instance" "absystem" {

  instance_type = "${var.absystem_instance_type}"

  ami = "${var.absystem_ami}"

  key_name = "${var.key_name}"

  count= "${var.absystem_instance_count}"

  subnet_id = "${aws_subnet.subnet_ap_south_1b.id}"

  vpc_security_group_ids = ["${aws_security_group.absystem_sg.id}"]

  tags {
    "Name" = "${format("${var.name_prefix}${var.cluster_vertical}ab%02d.${var.route53_zone}", count.index + 1)}"
    "Vertical" = "${var.cluster_vertical}"
    "App" ="absystem"
    "Role" = "abtesting"
    "Cluster" = "absystem-testing"
  }
}

# absystem Route 53 for absystem 
resource "aws_route53_record" "absystem" {
  count= "${var.absystem_instance_count}"
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "${format("${var.name_prefix}${var.cluster_vertical}ab%02d", count.index + 1)}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.absystem.*.private_ip, count.index)}"]
}