## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#Module      : Label
#Description : This terraform module is designed to generate consistent label names and
#              tags for resources. You can use terraform-labels to implement a strict
#              naming convention
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
  environment = var.environment
  label_order = var.label_order
}

#Module      : AWS_CLOUDWATCH_LOG_GROUP
#Description : Provides a CloudWatch Log Group resource.
resource "aws_cloudwatch_log_group" "cloudtrail_events" {
  count             = var.enabled ? 1 : 0
  name              = var.cloudwatch_logs_group_name
  retention_in_days = var.cloudwatch_logs_retention_in_days
  tags              = module.labels.tags
}

data "aws_iam_policy_document" "cloudwatch_delivery_assume_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

#Module      : AWS_IAM_ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "cloudwatch_delivery" {
  count              = var.enabled ? 1 : 0
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_delivery_assume_policy.json

  tags = module.labels.tags
}

#Module      : AWS_IAM_ROLE
#Description : Provides an IAM role policy.
resource "aws_iam_role_policy" "cloudwatch_delivery_policy" {
  count  = var.enabled ? 1 : 0
  name   = var.iam_role_policy_name
  role   = aws_iam_role.cloudwatch_delivery[0].id
  policy = data.aws_iam_policy_document.cloudwatch_delivery_policy[0].json
}

data "aws_iam_policy_document" "cloudwatch_delivery_policy" {
  count = var.enabled ? 1 : 0
  statement {
    sid       = "AWSCloudTrailCreateLogStream2014110"
    actions   = ["logs:CreateLogStream"]
    resources = [format("arn:aws:logs:%s:%s:log-group:%s:log-stream:*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, aws_cloudwatch_log_group.cloudtrail_events[0].name)]
  }
  statement {
    sid       = "AWSCloudTrailPutLogEvents20141101"
    actions   = ["logs:PutLogEvents"]
    resources = [format("arn:aws:logs:%s:%s:log-group:%s:log-stream:*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, aws_cloudwatch_log_group.cloudtrail_events[0].name)]
  }
}

# Module      : S3 BUCKET
# Description : Terraform module to create default S3 bucket with logging and encryption
#               type specific features.
module "s3_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git?ref=tags/0.12.2"

  name        = var.s3_bucket_name
  application = var.application
  environment = var.environment
  label_order = ["name"]

  create_bucket           = local.is_master_account
  bucket_enabled          = var.enabled
  region                  = data.aws_region.current.name
  versioning              = true
  acl                     = "log-delivery-write"
  bucket_policy           = true
  aws_iam_policy_document = data.aws_iam_policy_document.default.json
  force_destroy           = true
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

    resources = [format("arn:aws:s3:::%s", var.s3_bucket_name), ]
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

    resources = [format("arn:aws:s3:::%s/*", var.s3_bucket_name) ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

locals {
  is_individual_account = var.account_type == "individual"
  is_master_account     = var.account_type == "master"
  is_member_account     = var.account_type == "member"

  is_cloudtrail_enabled = local.is_individual_account || local.is_master_account
}

#Module      : CLOUDTRAIL
#Description : Terraform module to provision an AWS CloudTrail with encrypted S3 bucket.
#              This bucket is used to store CloudTrail logs.
module "cloudtrail" {
  source = "git::https://github.com/clouddrove/terraform-aws-cloudtrail.git?ref=tags/0.12.2"

  name                          = "cloudtrail"
  application                   = var.application
  environment                   = var.environment
  label_order                   = ["name", "application"]
  enabled_cloudtrail            = var.enabled
  s3_bucket_name                = format("%s",var.s3_bucket_name)
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = false
  kms_key_id                    = var.key_arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_events[0].arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_delivery[0].arn
}
