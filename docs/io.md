## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| EVENT\_ALERT\_LIST | Event List which event is not ignore. | `string` | `""` | no |
| EVENT\_IGNORE\_LIST | Event List which event is ignore. | `string` | `""` | no |
| SOURCE\_LIST | Event Source List which event is ignore. | `string` | `""` | no |
| USER\_IGNORE\_LIST | User List which event is ignore. | `string` | `""` | no |
| account\_type | The type of the AWS account. The possible values are `individual`, `master` and `member` . Specify `master` and `member` to set up centalized logging for multiple accounts in AWS Organization. Use individual` otherwise.` | `string` | `"individual"` | no |
| additional\_member\_root\_arn | Additional member root user arn. | `list(any)` | `[]` | no |
| additional\_member\_trail | Additional member trails. | `list(any)` | `[]` | no |
| cloudwatch\_logs\_group\_name | The name of CloudWatch Logs group to which CloudTrail events are delivered. | `string` | `"iam_role_name"` | no |
| cloudwatch\_logs\_retention\_in\_days | Number of days to retain logs for. CIS recommends 365 days.  Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely. | `number` | `365` | no |
| enable\_log\_file\_validation | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | `bool` | `true` | no |
| enable\_logging | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | `bool` | `true` | no |
| enabled | The boolean flag whether this module is enabled or not. No resources are created when set to false. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| iam\_role\_name | The name of the IAM Role to be used by CloudTrail to delivery logs to CloudWatch Logs group. | `string` | `"CloudTrail-CloudWatch-Delivery-Role"` | no |
| iam\_role\_policy\_name | The name of the IAM Role Policy to be used by CloudTrail to delivery logs to CloudWatch Logs group. | `string` | `"CloudTrail-CloudWatch-Delivery-Policy"` | no |
| include\_global\_service\_events | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | `bool` | `true` | no |
| is\_multi\_region\_trail | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | `bool` | `true` | no |
| is\_organization\_trail | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | `bool` | `false` | no |
| key\_arn | The arn of the KMS. | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| lambda\_enabled | Whether to create lambda for cloudtrail logs. | `bool` | `true` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | `string` | `"anmol@clouddrove.com"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| s3\_bucket\_name | The name of the S3 bucket which will store cloudtrail logs. | `string` | n/a | yes |
| s3\_log\_bucket\_name | The name of the S3 bucket which will store logs of bucket. | `string` | n/a | yes |
| s3\_policy | Policy of s3.. | `string` | `null` | no |
| slack\_channel | Channel of slack. | `string` | `""` | no |
| slack\_webhook | Webhook of slack. | `string` | `""` | no |
| sse\_algorithm | The server-side encryption algorithm to use. Valid values are AES256 and aws:kms. | `string` | `"AES256"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | The Amazon Resource Name of the trail |
| cloudtrail\_home\_region | The region in which the trail was created. |
| cloudtrail\_id | The name of the trail |
| log\_group\_name | The CloudWatch Logs log group which stores CloudTrail events. |
| s3\_arn | The ARN of S3 bucket. |
| s3\_id | The Name of S3 bucket. |
| tags | A mapping of tags to assign to the resource. |

