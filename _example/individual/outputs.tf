output "cloudtrail_arn" {
  value       = module.cloudtrail.*.cloudtrail_arn
  description = "The Amazon Resource Name of the trail"
}

output "kms_arn" {
  value       = module.cloudtrail.*.kms_arn
  description = "The Amazon Resource Name of the kms"
}

output "tags" {
  value       = module.cloudtrail.tags
  description = "A mapping of tags to assign to the Cloudtrail."
}
