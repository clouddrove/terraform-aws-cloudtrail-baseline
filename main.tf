## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#Module      : Label
#Description : This terraform module is designed to generate consistent label names and
#              tags for resources. You can use terraform-labels to implement a strict
#              naming convention
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.14.0"

  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby
  enabled     = var.enabled
}


# Module      : S3 BUCKET
# Description : Terraform module to create default S3 bucket with logging and encryption
#               type specific features.

module "s3_log_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git?ref=tags/0.14.0"

  name           = var.s3_log_bucket_name
  environment    = var.environment
  label_order    = ["name"]
  managedby      = var.managedby
  create_bucket  = local.is_cloudtrail_enabled
  bucket_enabled = var.enabled
  versioning     = true
  acl            = "private"
}

module "s3_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git?ref=tags/0.14.0"

  name                    = var.s3_bucket_name
  environment             = var.environment
  label_order             = ["name"]
  managedby               = var.managedby
  create_bucket           = local.is_cloudtrail_enabled && var.secure_s3_enabled == false
  bucket_logging_enabled  = var.enabled && var.secure_s3_enabled == false
  versioning              = true
  acl                     = "private"
  bucket_policy           = true
  aws_iam_policy_document = var.s3_policy
  force_destroy           = true
  target_bucket           = module.s3_log_bucket.id
  target_prefix           = "logs"
  mfa_delete              = var.mfa_delete
}

module "secure_s3_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git?ref=tags/0.14.0"

  name                              = var.s3_bucket_name
  environment                       = var.environment
  label_order                       = ["name"]
  managedby                         = var.managedby
  create_bucket                     = local.is_cloudtrail_enabled && var.secure_s3_enabled
  bucket_logging_encryption_enabled = var.enabled && var.secure_s3_enabled
  versioning                        = true
  acl                               = "private"
  bucket_policy                     = true
  aws_iam_policy_document           = var.s3_policy
  force_destroy                     = true
  sse_algorithm                     = var.sse_algorithm
  kms_master_key_id                 = var.key_arn == "" ? module.kms_key.key_arn : var.key_arn
  target_bucket                     = module.s3_log_bucket.id
  target_prefix                     = "logs"
  mfa_delete                        = var.mfa_delete
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
    resources = [format("arn:aws:logs:%s:%s:log-group:%s:log-stream:*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, join("", aws_cloudwatch_log_group.cloudtrail_events.*.name))]
  }
  statement {
    sid       = "AWSCloudTrailPutLogEvents20141101"
    actions   = ["logs:PutLogEvents"]
    resources = [format("arn:aws:logs:%s:%s:log-group:%s:log-stream:*", data.aws_region.current.name, data.aws_caller_identity.current.account_id, join("", aws_cloudwatch_log_group.cloudtrail_events.*.name))]
  }
}

module "kms_key" {
  source = "git::https://github.com/clouddrove/terraform-aws-kms.git?ref=tags/1.3.1"

  name                    = var.name
  environment             = var.environment
  label_order             = var.label_order
  managedby               = var.managedby
  is_enabled              = true
  enabled                 = local.is_cloudtrail_enabled
  description             = "KMS key for cloudtrail"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/cloudtrail"
  policy                  = data.aws_iam_policy_document.cloudtrail_key_policy.json
}

data "aws_iam_policy_document" "cloudtrail_key_policy" {
  policy_id = "Key policy created for CloudTrail"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type = "AWS"
      identifiers = compact(
        concat(
          [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)],
          var.additional_member_root_arn
        )
      )
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "Allow CloudTrail to encrypt logs"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = compact(
        concat(
          [format("arn:aws:cloudtrail:*:%s:trail/*", data.aws_caller_identity.current.account_id)]
        )
      )
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudtrail:us-east-1:156873913342:trail/<trail_Name>"
      ]
    }
  }

  statement {
    sid = "Allow CloudTrail to describe key"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = compact(
        concat(
          [data.aws_caller_identity.current.account_id]
        )
      )
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = compact(
        concat(
          [format("arn:aws:cloudtrail:*:%s:trail/*", data.aws_caller_identity.current.account_id)],
          var.additional_member_trail
        )
      )
    }
  }
  statement {
    sid = "Allow alias creation during setup"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = compact(
        concat(
          [
          data.aws_caller_identity.current.account_id]
        )
      )
    }
  }
  statement {
    sid = "Enable cross account log decryption"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = compact(
        concat(
          [data.aws_caller_identity.current.account_id]
        )
      )
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = compact(
        concat(
          [format("arn:aws:cloudtrail:*:%s:trail/*", data.aws_caller_identity.current.account_id)]
        )
      )
    }
  }

  statement {
    sid = "Allow use of the key"
    principals {
      type = "AWS"
      identifiers = compact(
        concat(
          [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]
        )
      )
    }
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"
    principals {
      type = "AWS"
      identifiers = compact(
        concat(
          [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]
        )
      )
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
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
  source = "git::https://github.com/clouddrove/terraform-aws-cloudtrail.git?ref=tags/0.14.0"

  name                          = var.name
  environment                   = var.environment
  label_order                   = ["name", "environment"]
  managedby                     = var.managedby
  enabled_cloudtrail            = var.enabled
  s3_bucket_name                = format("%s", var.s3_bucket_name)
  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = var.key_arn == "" ? module.kms_key.key_arn : var.key_arn
  cloud_watch_logs_group_arn    = join("", aws_cloudwatch_log_group.cloudtrail_events.*.arn)
  cloud_watch_logs_role_arn     = join("", aws_iam_role.cloudwatch_delivery.*.arn)
}

module "cloudtrail-slack-notification" {
  source = "git::https://github.com/clouddrove/terraform-aws-cloudtrail-slack-notification.git?ref=tags/1.0.1"

  name        = "cloudtrail-slack-notification"
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  enabled     = var.lambda_enabled && local.is_cloudtrail_enabled
  bucket_arn  = format("arn:aws:s3:::%s", var.s3_bucket_name)
  bucket_name = var.s3_bucket_name
  variables = {
    SLACK_WEBHOOK     = var.slack_webhook
    SLACK_CHANNEL     = var.slack_channel
    EVENT_IGNORE_LIST = var.EVENT_IGNORE_LIST
    EVENT_ALERT_LIST  = var.EVENT_ALERT_LIST
    USER_IGNORE_LIST  = var.USER_IGNORE_LIST
    SOURCE_LIST       = var.SOURCE_LIST
  }
}
