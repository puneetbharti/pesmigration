import boto3
client = boto3.client('es')
ARN="arn:aws:logs:ap-south-1:040866577337:log-group:/aws/aes/domains/plivoes/search-logs:*"
LogPublishingOptions = {}
LogPublishingOptions["INDEX_SLOW_LOGS"] = {'CloudWatchLogsLogGroupArn': ARN,'Enabled': True}
LogPublishingOptions["SEARCH_SLOW_LOGS"] = {'CloudWatchLogsLogGroupArn': ARN,'Enabled': True}
print(LogPublishingOptions)

AdvancedOptions={'rest.action.multi.allow_explicit': 'false'}

response = client.update_elasticsearch_domain_config(DomainName="plivoes", LogPublishingOptions=LogPublishingOptions)


print(response)
