provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

module "cloudtrail" {
  source = "./../../"

  name        = "trails"
  environment = "test"
  label_order = ["environment", "name"]

  enabled                           = true
  iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
  account_type                      = "individual"
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  EVENT_IGNORE_LIST                 = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
  EVENT_ALERT_LIST                  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
  USER_IGNORE_LIST                  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
  SOURCE_LIST                       = jsonencode(["aws-sdk-go"])

  s3_bucket_name     = "logs-bucket-clouddrove"
  s3_log_bucket_name = "s3-logs-bucket-clouddrove"
  slack_webhook      = "https://hooks.slack.com/services/TEFGGGF0QZ/BPertgrSFGHTLAH/rCldcdrgreffdfsedg0jRSpZ7GVEtJr46llretqX"
  slack_channel      = "testing"
  s3_policy          = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = ["arn:aws:s3:::logs-bucket-clouddrove"]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = compact(
      concat(
        [format("arn:aws:s3:::logs-bucket-clouddrove/AWSLogs/%s/*", data.aws_caller_identity.current.account_id)]
      )
    )

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}
