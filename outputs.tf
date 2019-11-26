
output "cloudtrail_id" {
  value       = module.cloudtrail.id
  description = "The name of the trail"
}

output "cloudtrail_arn" {
  value       = module.cloudtrail.arn
  description = "The Amazon Resource Name of the trail"
}

output "cloudtrail_home_region" {
  value       = module.cloudtrail.home_region
  description = "The region in which the trail was created."
}

output "s3_id" {
  value       = module.s3_bucket.id
  description = "The Name of S3 bucket."
}

output "s3_arn" {
  value       = module.s3_bucket.arn
  description = "The ARN of S3 bucket."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
