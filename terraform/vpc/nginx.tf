##
# Nginx
##

# Nginx Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  description = "nginx inbound traffic"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  depends_on = ["aws_security_group.bastion_sg"]

  tags {
    Name = "nginx_sg"
  }
}

#nginx instances
resource "aws_instance" "nginx" {

  instance_type = "${var.nginx_instance_type}"

  ami = "${var.nginx_ami}"

  key_name = "${var.key_name}"

  count= "${var.nginx_instance_count}"

  subnet_id = "${aws_subnet.subnet_ap_south_1b.id}"

  vpc_security_group_ids = ["${aws_security_group.nginx_sg.id}"]

  tags {
    "Name" = "${format("${var.name_prefix}${var.cluster_vertical}nginx%02d.${var.route53_zone}", count.index + 1)}"
    "Vertical" = "${var.cluster_vertical}"
    "App" ="nginx"
    "Role" = "proxy"
    "Cluster" = "nginx-proxy"
  }
}

# Nginx Route 53 for nginx 
resource "aws_route53_record" "nginx" {
  count= "${var.nginx_instance_count}"
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "${format("${var.name_prefix}${var.cluster_vertical}nginx%02d", count.index + 1)}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.nginx.*.private_ip, count.index)}"]
}