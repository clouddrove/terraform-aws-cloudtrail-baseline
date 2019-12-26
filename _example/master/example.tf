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

  s3_bucket_name                 = "logs-bucket-clouddrove"
  slack_webhook                  = "https://hooks.slack.com/services/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"
  slack_channel                  = "testing"
  additional_member_root_arn     = ["arn:aws:iam::xxxxxxxxxxx:root"]
  additional_member_trail        = ["arn:aws:cloudtrail:*:xxxxxxxxxxx:trail/*"]
  additional_member_account_id   = ["xxxxxxxxxxx"]
  additional_s3_account_path_arn = ["arn:aws:s3:::logs-bucket-clouddrove/AWSLogs/xxxxxxxxxxx/*"]
}
