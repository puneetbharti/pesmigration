# logstash instance 
resource "null_resource" "logstash" {
  # triggers {
  #   cluster_instance_ids = "${join(",", aws_instance.logstash.*.id)}"
  # }
  # triggers {
  #   cluster_instance_ids = "${join(",", aws_route53_record.logstash.*.id)}"
  # }

  # count= "${var.logstash_instance_count}"

  # connection {
  #   host = "${format("${var.name_prefix}${var.cluster_vertical}logstash%02d", count.index + 1)}"
  #   user = "puneet"
  #   private_key = true
  # }

  # provisioner "-exec" {
  #   # Bootstrap script called with private_ip of each node in the clutser
  #   inline = [
  #     "bootstrap.sh ${format("${var.name_prefix}${var.cluster_vertical}logstash%02d", count.index + 1)}",
  #   ]
  # }
  
  # provisioner "local-exec" {
  #   command = "echo '[local]\n localhost\n [all:vars]\n ansible_ssh_user=ubuntu \n ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem \n [${var.cluster_vertical}]' > ${path.module}/../../ansible/inventories/logstash.ini"
  # }

  # provisioner "local-exec" {
  #   command = "echo ${format("${var.name_prefix}${var.cluster_vertical}logstash%02d.${var.route53_zone}", count.index + 1)} >> ${path.module}/../../ansible/inventories/logstash.ini"
  # }

  #  provisioner "local-exec" {
  #   command = "cd ${path.module}/../../ansible/ && ansible-playbook -e ANSIBLE_HOST_KEY_CHECKING=False -i inventories/logstash.ini setup.yml --extra-vars='hosts=${var.cluster_vertical} vertical_name=${var.cluster_vertical}'"
  # }
}