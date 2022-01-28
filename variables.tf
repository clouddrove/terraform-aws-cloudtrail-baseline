#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "The boolean flag whether this module is enabled or not. No resources are created when set to false."
}

variable "lambda_enabled" {
  type        = bool
  default     = true
  description = "Whether to create lambda for cloudtrail logs."
}

variable "secure_s3_enabled" {
  type        = bool
  default     = true
  description = "Whether to create secure s3 for cloudtrail logs."
}

variable "mfa_delete" {
  type        = bool
  default     = false
  description = "Whether to enable mfa_delete or not."
}

variable "target_log_prefix" {
  type        = string
  default     = ""
  description = "To specify a key prefix for log objects."
}

variable "target_log_bucket" {
  type        = string
  default     = ""
  description = "To specify a bucket for log objects."
}

variable "cloudtrail_name" {
  type        = string
  default     = "cloudtrail-multi-region"
  description = "The name of the trail."
}

variable "slack_webhook" {
  type        = string
  default     = ""
  description = "Webhook of slack."
}

variable "slack_channel" {
  type        = string
  default     = ""
  description = "Channel of slack."
}

variable "additional_member_root_arn" {
  type        = list(any)
  default     = []
  description = "Additional member root user arn."
}

variable "additional_member_trail" {
  type        = list(any)
  default     = []
  description = "Additional member trails."
}

variable "additional_member_account_id" {
  type        = list(any)
  default     = []
  description = "Additional member account id."
}

variable "additional_s3_account_path_arn" {
  type        = list(any)
  default     = []
  description = "Additional path of s3 account."
}

variable "cloudwatch_logs_group_name" {
  type        = string
  default     = "iam_role_name"
  description = "The name of CloudWatch Logs group to which CloudTrail events are delivered."
}

variable "cloudwatch_logs_retention_in_days" {
  type        = number
  default     = 365
  description = "Number of days to retain logs for. CIS recommends 365 days.  Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely."
}

variable "lifecycle_days_to_expiration" {
  type        = number
  default     = 365
  description = "Number of days to expire."
}

variable "iam_role_name" {
  type        = string
  default     = "CloudTrail-CloudWatch-Delivery-Role"
  description = "The name of the IAM Role to be used by CloudTrail to delivery logs to CloudWatch Logs group."
}

variable "filename" {
  type        = string
  default     = ""
  description = "The path of directory of code."
}

variable "iam_role_policy_name" {
  type        = string
  default     = "CloudTrail-CloudWatch-Delivery-Policy"
  description = "The name of the IAM Role Policy to be used by CloudTrail to delivery logs to CloudWatch Logs group."
}

variable "key_deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."

}

variable "s3_log_bucket_name" {
  type        = string
  description = "The name of the S3 bucket which will store logs of bucket."
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket which will store cloudtrail logs."
}

variable "key_arn" {
  type        = string
  default     = ""
  description = "The arn of the KMS."
}

variable "account_ids" {

  default     = {}
  description = "The account id of the accounts."
}

variable "s3_key_prefix" {
  type        = string
  default     = ""
  description = "The prefix for the specified S3 bucket."
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
}

variable "account_type" {
  type        = string
  default     = "individual"
  description = "The type of the AWS account. The possible values are `individual`, `master` and `member` . Specify `master` and `member` to set up centalized logging for multiple accounts in AWS Organization. Use individual` otherwise."
}

variable "EVENT_IGNORE_LIST" {
  type        = string
  default     = ""
  description = "Event List which event is ignore."
}

variable "EVENT_ALERT_LIST" {
  type        = string
  default     = ""
  description = "Event List which event is not ignore."
}

variable "USER_IGNORE_LIST" {
  type        = string
  default     = ""
  description = "User List which event is ignore."
}

variable "SOURCE_LIST" {
  type        = string
  default     = ""
  description = "Event Source List which event is ignore."
}

variable "s3_policy" {
  default     = []
  description = "Policy of s3.."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms."
}

variable "kms_master_key_id" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
}

variable "tracing_mode" {
  type        = string
  default     = null
  description = "Whether to to sample and trace a subset of incoming requests with AWS X-Ray. Valid values are PassThrough and Active."
}

variable "attach_tracing_policy" {
  type        = bool
  default     = false
  description = "Controls whether X-Ray tracing policy should be added to IAM role for Lambda Function"
}