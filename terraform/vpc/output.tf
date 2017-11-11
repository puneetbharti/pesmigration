output "aws_es_domain" {
  value = ["${aws_elasticsearch_domain.elasticsearch.domain_name}"]
}