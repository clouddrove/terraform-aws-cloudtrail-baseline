provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "kms_key" {
  source = "git::https://github.com/clouddrove/terraform-aws-kms.git?ref=tags/0.12.1"

  name                    = "kms"
  application = "clouddrove"
  environment = "test"
  label_order             = ["environment", "name", "application"]
  is_enabled              = true
  description             = "KMS key for cloudtrail"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/cloudtrail"
  policy                  = data.aws_iam_policy_document.cloudtrail_key_policy.json
}

data "aws_iam_policy_document" "cloudtrail_key_policy" {
  policy_id = "Key policy created by CloudTrail"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]
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
      values = [
      format("arn:aws:cloudtrail:*:%s:trail/*", data.aws_caller_identity.current.account_id)]
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
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
      format("arn:aws:cloudtrail:*:%s:trail/*", data.aws_caller_identity.current.account_id)]
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
      values   = [data.aws_caller_identity.current.account_id]
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
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = [format("arn:aws:cloudtrail:*:%s:trail/*", data.aws_caller_identity.current.account_id)]
    }
  }

  statement {
    sid = "Allow use of the key"
    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root",data.aws_caller_identity.current.account_id)]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"
    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root",data.aws_caller_identity.current.account_id)]
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
  key_arn        = module.kms_key.key_arn

  s3_bucket_name = "logs-bucket-clouddrove"
}

module "cloudtrail-slack-notification" {
  source = "git::https://github.com/clouddrove/terraform-aws-cloudtrail-slack-notification.git"

  name        = "cloudtrail-slack-notification"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  enabled     = true
  bucket_arn  = "arn:aws:s3:::logs-bucket-clouddrove"
  bucket_name = "logs-bucket-clouddrove"
  filename    = "./../../cloudtrail_slack_notification"
  variables = {
    SLACK_WEBHOOK     = "https://hooks.slack.com/services/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"
    SLACK_CHANNEL     = "testing"
    EVENT_IGNORE_LIST = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
    EVENT_ALERT_LIST  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
    USER_IGNORE_LIST  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
    SOURCE_LIST       = jsonencode(["signin.amazonaws.com"])
  }
}