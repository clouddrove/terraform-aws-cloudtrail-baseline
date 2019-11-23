

output "log_delivery_iam_role" {
  description = "The IAM role used for delivering CloudTrail events to CloudWatch Logs."
  value       = var.enabled ? aws_iam_role.cloudwatch_delivery[0] : null
}

output "log_group" {
  description = "The CloudWatch Logs log group which stores CloudTrail events."
  value       = var.enabled ? aws_cloudwatch_log_group.cloudtrail_events[0] : null
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}