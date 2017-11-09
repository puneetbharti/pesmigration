# elastic search cloudwatch metric alarm 
resource "aws_cloudwatch_metric_alarm" "aws_es_alarm" {
  alarm_name          = "${var.es_cluster_name}-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "1"

  dimensions {
    DomainName = "${var.es_cluster_name}"
  }

  alarm_description = "This metric monitors ${var.es_cluster_name}"
  #alarm_actions     = ["${aws_elasticsearch_domain.elasticsearch.arn}"]
}

resource "aws_cloudwatch_log_group" "aws_es_log_group" {
  name = "/aws/aes/domains/plivoes/search-logs"
}

resource "aws_cloudwatch_log_stream" "aws_es_log_stream" {
  name           = "awses_log_stream"
  log_group_name = "${aws_cloudwatch_log_group.aws_es_log_group.name}"
}

