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
  name = "/aws/aes/domains/plivoes/singapore/search-logs"
}

resource "aws_cloudwatch_log_stream" "aws_es_log_stream" {
  name           = "aws_es_log_stream"
  log_group_name = "${aws_cloudwatch_log_group.aws_es_log_group.name}"
}

# resource "aws_iam_role" "aws_es_iam" {
#   name = "aws_es_custom_role"
#   assume_role_policy =<<EOF
#	{"Version": "2012-10-17","Statement": [{"Action": "sts:AssumeRole","Principal": {"Service": "es.amazonaws.com"},"Effect": "Allow","Sid": ""}]}
#   EOF
#}


# resource "aws_cloudwatch_log_destination" "aws_es_log_destination" {
#   name       = "aws_es_log_destination"
#   role_arn   = "${aws_iam_role.aws_es_iam.arn}"
#   target_arn = "${aws_elasticsearch_domain.elasticsearch.arn}"
# }

# data "aws_iam_policy_document" "aws_es_log_destination_policy" {
#   statement {
#     effect = "Allow"

#     principals = {
#         type = "AWS"
#         identifiers = [
#         "123456789012",
#       ]
#     }

#     actions = [
#         "logs:PutLogEvents",
#         "logs:CreateLogStream"
#     ]
#     resources = [
#       "${aws_cloudwatch_log_destination.aws_es_log_destination.arn}",
#     ]
#   }
# }

# resource "aws_cloudwatch_log_destination_policy" "aws_es_log_destination_policy" {
#   destination_name = "${aws_cloudwatch_log_destination.aws_es_log_destination.name}"
#   access_policy    = "${data.aws_iam_policy_document.aws_es_log_destination_policy.json}"
# }
