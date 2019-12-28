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
  iam_role_name                     = "CloudTrail-cd-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-cd-Delivery-Policy"
  account_type                      = "member"
  key_deletion_window_in_days       = 10
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  key_arn                           = "arn:aws:kms:eu-west-1:xxxxxxxxxx:key/67b18b57-71cb-4997-8884-f723cf4a7dc2"
  filename                          = "./../../cloudtrail_slack_notification"

  s3_bucket_name = "logs-bucket-clouddrove"
}
