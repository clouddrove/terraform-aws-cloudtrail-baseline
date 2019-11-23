
output "log_group" {
  value       = module.cloudtrail.*.log_group
  description = "The CloudWatch Logs log group which stores CloudTrail events."
}

output "tags" {
  value       = module.cloudtrail.tags
  description = "A mapping of tags to assign to the resource."
}