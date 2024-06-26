#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
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

variable "iam_role_name" {
  type        = string
  default     = "CloudTrail-CloudWatch-Delivery-Role"
  description = "The name of the IAM Role to be used by CloudTrail to delivery logs to CloudWatch Logs group."
}

variable "iam_role_policy_name" {
  type        = string
  default     = "CloudTrail-CloudWatch-Delivery-Policy"
  description = "The name of the IAM Role Policy to be used by CloudTrail to delivery logs to CloudWatch Logs group."
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

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
}

variable "include_global_service_events" {
  type        = bool
  default     = true
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
}

variable "enable_log_file_validation" {
  type        = bool
  default     = true
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
}

variable "enable_logging" {
  type        = bool
  default     = true
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
  type        = string
  default     = null
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

