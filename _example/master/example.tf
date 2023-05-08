provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "cloudtrail" {
  source = "./../../"

  name        = "trails"
  environment = "test"
  label_order = ["environment", "name"]

  enabled                           = true
  iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
  account_type                      = "master"
  key_deletion_window_in_days       = 10
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  EVENT_IGNORE_LIST                 = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
  EVENT_ALERT_LIST                  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
  USER_IGNORE_LIST                  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
  SOURCE_LIST                       = jsonencode(["aws-sdk-go"])

  s3_bucket_name                 = "logs-bucket-cd"
  secure_s3_enabled              = false
  s3_log_bucket_name             = "logs-bucket-cd-logs"
  sse_algorithm                  = "aws:kms"
  slack_webhook                  = "https://hooks.slack.com/services/TEE0GHDK0F0QZ/B015frHRDBEUFHEVEG/dfdrfrefrwewqe"
  slack_channel                  = "testing"
  is_organization_trail          = true
  additional_member_root_arn     = ["arn:aws:iam::xxxxxxxxxxxx:root"]
  additional_member_trail        = ["arn:aws:cloudtrail:*:xxxxxxxxxxxx:trail/*"]
  additional_member_account_id   = ["xxxxxxxxxxxx"]
  additional_s3_account_path_arn = ["arn:aws:s3:::logs-bucket-clouddrove/AWSLogs/xxxxxxxxxxxx/*"]
  s3_policy                      = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = ["arn:aws:s3:::test-cloudtrail-logs"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:cloudtrail:us-east-1:156873913342:trail/cloudtrails-test"
      ]
    }
  }


  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = ["arn:aws:s3:::test-cloudtrail-logs/AWSLogs/156873913342/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }  

  statement {
    sid = "AWSCloudTrailWrite20150319"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:*"
    ]

    resources = compact(
      concat(
        [format("arn:aws:s3:::test-cloudtrail-logs/AWSLogs/%s/*", data.aws_caller_identity.current.account_id), "arn:aws:s3:::test-cloudtrail-logs/AWSLogs/156873913342/*"]
      )
    )

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:cloudtrail:us-east-1:156873913342:trail/cloudtrails-test"
      ]
    }    
  }
} 
