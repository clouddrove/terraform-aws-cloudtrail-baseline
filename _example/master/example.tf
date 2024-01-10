provider "aws" {
  region = "us-east-1"
}

module "cloudtrail" {
  source                            = "./../../"
  name                              = "test-cloudtrail"
  environment                       = "main"
  label_order                       = ["environment", "name"]
  enabled                           = true
  iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
  account_type                      = "master"
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  EVENT_IGNORE_LIST                 = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
  EVENT_ALERT_LIST                  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
  USER_IGNORE_LIST                  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
  SOURCE_LIST                       = jsonencode(["aws-sdk-go"])
  s3_bucket_name                    = "test-cloudtrail-bucket"
  secure_s3_enabled                 = false
  s3_log_bucket_name                = "test-clouddtrail-logs"
  sse_algorithm                     = "aws:kms"
  additional_member_root_arn        = ["arn:aws:iam::xxxxxxxxxxxx:root"]
  additional_member_trail           = ["arn:aws:cloudtrail:*:xxxxxxxxxxxx:trail/*"]
  s3_policy                         = data.aws_iam_policy_document.default.json
}


data "aws_iam_policy_document" "default" {
  statement {
    sid = "AWSCloudTrailAclCheck20150319"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = ["arn:aws:s3:::test-cloudtrail-bucket"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:cloudtrail:us-east-1:xxxxxxxxxxxx:trail/xcheck-trails"
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
      "s3:PutObject"
    ]

    resources = ["arn:aws:s3:::test-cloudtrail-bucket/AWSLogs/xxxxxxxxxxxx/*"]

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
        "arn:aws:cloudtrail:us-east-1:xxxxxxxxxxxx:trail/xcheck-trails"
      ]
    }
  }

  statement {
    sid = "AWSCloudTrailWrite2015031"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = ["arn:aws:s3:::logs-bucket-cd-test/AWSLogs/<AWS_ORGANIZATION_ID>/*"]

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
        "arn:aws:cloudtrail:us-east-1:xxxxxxxxxxxx:trail/xcheck-trails"
      ]
    }
  }
}
