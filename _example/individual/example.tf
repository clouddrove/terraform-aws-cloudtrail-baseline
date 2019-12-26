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
  account_type                      = "individual"
  key_deletion_window_in_days       = 10
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  filename                          = "./../../cloudtrail_slack_notification"

  s3_bucket_name                 = "logs-bucket-clouddrove"
  slack_webhook                  = "https://hooks.slack.com/services/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7GVEtJr46llqX"
  slack_channel                  = "testing"
}
