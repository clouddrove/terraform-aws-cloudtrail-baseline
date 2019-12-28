provider "aws" {
  region = "eu-west-1"
}

module "cloudtrail" {
  source = "./../../"

  name        = "trails"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  enabled                           = true
  iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
  account_type                      = "master"
  key_deletion_window_in_days       = 10
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  filename                          = "./../../cloudtrail_slack_notification"
  EVENT_IGNORE_LIST = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
  EVENT_ALERT_LIST  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
  USER_IGNORE_LIST  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
  SOURCE_LIST       = jsonencode(["aws-sdk-go"])

  s3_bucket_name                 = "logs-bucket-clouddrove"
  slack_webhook                  = "https://hooks.slack.com/services/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46llqX"
  slack_channel                  = "testing"
  additional_member_root_arn     = ["arn:aws:iam::xxxxxxxxxx:root"]
  additional_member_trail        = ["arn:aws:cloudtrail:*:xxxxxxxxxx:trail/*"]
  additional_member_account_id   = ["xxxxxxxxxx"]
  additional_s3_account_path_arn = ["arn:aws:s3:::logs-bucket-clouddrove/AWSLogs/xxxxxxxxxx/*"]
}