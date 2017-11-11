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
