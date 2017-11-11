# Elasticsearch elb security group
resource "aws_security_group" "aws_internal_es_sg" {
  name        = "aws_internal_es_sg"
  description = "aws_internal_es_sg"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
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
# elasticsearch elb
resource "aws_elb" "elasticsearch-1-4-2-cluster" {
  name               = "elasticsearch-1-4-2-cluster"
  subnets = ["${aws_subnet.subnet_ap_south_1b.id}"]
  security_groups =  ["${aws_security_group.aws_internal_es_sg.id}"]

  listener {
    instance_port     = 9200
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:9200/"
    interval            = 30
  }

  internal = true
  instances                   = ["${aws_instance.elasticsearch.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    "Vertical" = "${var.cluster_vertical}"
    "App" ="elasticsearchelb"
    "Role" = "logsearch"
    "Version" ="1.4.2"
    "Cluster" = "elasticsearch-logsearch"
  }
}

##  Elasticsearch 1.4.2 route 53 record 
resource "aws_route53_record" "aws_internal_es_dns" {
  count= 1
  zone_id = "${aws_route53_zone.plivo_zone.zone_id}"
  name = "oldes"
  type = "CNAME"
  ttl = "3"
  records = ["${aws_elb.elasticsearch-1-4-2-cluster.dns_name}"]
}


# Elasticsearch elb security group
resource "aws_security_group" "www_sg" {
  name        = "www_sg"
  description = "www_sg"
  vpc_id = "${aws_vpc.plivo_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "www_sg"
  }
}
# frontend elb
resource "aws_elb" "plivo-frontend" {
  name               = "plivo-frontend"
  subnets = ["${aws_subnet.subnet_ap_south_1b.id}", "${aws_subnet.subnet_ap_south_1a.id}"]
  security_groups =  ["${aws_security_group.www_sg.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  internal = false
  instances                   = ["${aws_instance.nginx.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    "Vertical" = "${var.cluster_vertical}"
  }
}

#plivo dashboard
resource "aws_elb" "plivo-dashboard" {
  name               = "plivo-dashboard"
  subnets = ["${aws_subnet.subnet_ap_south_1b.id}", "${aws_subnet.subnet_ap_south_1a.id}"]
  security_groups =  ["${aws_security_group.www_sg.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  internal = false
  instances                   = ["${aws_instance.es_proxy.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    "Vertical" = "${var.cluster_vertical}"
  }
}