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
  iam_role_name                     = "CloudTrail-cd-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-cd-Delivery-Policy"
  account_type                      = "member"
  cloudwatch_logs_retention_in_days = 365
  cloudwatch_logs_group_name        = "cloudtrail-log-group"
  key_arn                           = "arn:aws:kms:eu-west-1:xxxxxxxxxxx:key/9f3b66a0-3a38-4ed3-ab34-5e47c7e3604b"

  s3_bucket_name     = "logs-bucket-cd"
  s3_log_bucket_name = "logs-bucket-cd-logs"
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
