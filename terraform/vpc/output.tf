output "gateway_elastic_ip" {
  value = ["${aws_eip.bastion.public_ip}"]
}

output "aws_kibana_dashboard" {
  value = ["${aws_elb.plivo-dashboard.dns_name}"]
}

output "plivo_frontend" {
  value = ["${aws_elb.plivo-frontend.dns_name}"]
}


