resource "aws_elb" "elasticsearch-1-4-2-cluster" {
  name               = "elasticsearch-1-4-2-cluster"
  subnets = ["${aws_subnet.subnet_ap_south_1b.id}", "${aws_subnet.subnet_ap_south_1a.id}"]

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