<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS Cloudtrail Baseline
</h1>

<p align="center" style="font-size: 1.2rem;">
    Terraform module to create an cloudtrail resource on AWS with S3 encryption with KMS key.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.12-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-cloudtrail-baseline'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+Cloudtrail+Baseline&url=https://github.com/clouddrove/terraform-aws-cloudtrail-baseline'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+Cloudtrail+Baseline&url=https://github.com/clouddrove/terraform-aws-cloudtrail-baseline'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure.

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies:

- [Terraform 0.13](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-cloudtrail-baseline/releases).


Here are some examples of how you can use this module in your inventory structure:

### Individual Account
```hcl
  module "cloudtrail" {
    source                            = "git::https://github.com/clouddrove/terraform-aws-cloudtrail-baseline.git?ref=tags/0.12.12"
    name                              = "trails"
    application                       = "clouddrove"
    environment                       = "test"
    label_order                       = ["environment", "application", "name"]
    enabled                           = true
    iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
    iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
    account_type                      = "individual"
    key_deletion_window_in_days       = 10
    cloudwatch_logs_retention_in_days = 365
    cloudwatch_logs_group_name        = "cloudtrail-log-group"
    EVENT_IGNORE_LIST                 = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
    EVENT_ALERT_LIST                  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
    USER_IGNORE_LIST                  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
    SOURCE_LIST                       = jsonencode(["aws-sdk-go"])
    s3_bucket_name                    = "logs-bucket-clouddrove"
    slack_webhook                     = "https://hooks.slack.com/services/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GVEtJr46llqX"
    slack_channel                     = "testing"
  }
```

### Multi Account

#### Master Account
```hcl
  module "cloudtrail" {
    source                            = "git::https://github.com/clouddrove/terraform-aws-cloudtrail-baseline.git?ref=tags/0.12.12"
    name                              = "trails"
    application                       = "clouddrove"
    environment                       = "test"
    label_order                       = ["environment", "application", "name"]
    enabled                           = true
    iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
    iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
    account_type                      = "master"
    key_deletion_window_in_days       = 10
    cloudwatch_logs_retention_in_days = 365
    cloudwatch_logs_group_name        = "cloudtrail-log-group"
    s3_bucket_name                    = "logs-bucket-clouddrove"
    slack_webhook                     = "https://hooks.slack.com/services/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Jr46llqX"
    slack_channel                     = "testing"
    EVENT_IGNORE_LIST                 = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
    EVENT_ALERT_LIST                  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
    USER_IGNORE_LIST                  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
    SOURCE_LIST                       = jsonencode(["aws-sdk-go"])
    additional_member_root_arn        = ["arn:aws:iam::xxxxxxxxxxx:root"]
    additional_member_trail           = ["arn:aws:cloudtrail:*:xxxxxxxxxxx:trail/*"]
    additional_member_account_id      = ["xxxxxxxxxxx"]
    additional_s3_account_path_arn    = ["arn:aws:s3:::logs-bucket-clouddrove/AWSLogs/xxxxxxxxxxx/*"]
  }
```

#### Member Account
```hcl
  module "cloudtrail" {
    source                            = "git::https://github.com/clouddrove/terraform-aws-cloudtrail-baseline.git?ref=tags/0.12.12"
    name                              = "trails"
    application                       = "clouddrove"
    environment                       = "test"
    label_order                       = ["environment", "application", "name"]
    enabled                           = true
    iam_role_name                     = "CloudTrail-cd-Delivery-Role"
    iam_role_policy_name              = "CloudTrail-cd-Delivery-Policy"
    account_type                      = "member"
    key_deletion_window_in_days       = 10
    cloudwatch_logs_retention_in_days = 365
    cloudwatch_logs_group_name        = "cloudtrail-log-group"
    key_arn                           = "arn:aws:kms:eu-west-1:xxxxxxxxxxx:key/66cc5610-3b90-460b-a177-af89e119fdaa"
    s3_bucket_name                    = "logs-bucket-clouddrove"
  }
```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| EVENT\_ALERT\_LIST | Event List which event is not ignore. | string | `""` | no |
| EVENT\_IGNORE\_LIST | Event List which event is ignore. | string | `""` | no |
| SOURCE\_LIST | Event Source List which event is ignore. | string | `""` | no |
| USER\_IGNORE\_LIST | User List which event is ignore. | string | `""` | no |
| account\_ids | The account id of the accounts. | map | `<map>` | no |
| account\_type | The type of the AWS account. The possible values are `individual`, `master` and `member` . Specify `master` and `member` to set up centalized logging for multiple accounts in AWS Organization. Use individual` otherwise. | string | `"individual"` | no |
| additional\_member\_account\_id | Additional member account id. | list | `<list>` | no |
| additional\_member\_root\_arn | Additional member root user arn. | list | `<list>` | no |
| additional\_member\_trail | Additional member trails. | list | `<list>` | no |
| additional\_s3\_account\_path\_arn | Additional path of s3 account. | list | `<list>` | no |
| application | Application \(e.g. `cd` or `clouddrove`\). | string | `""` | no |
| attributes | Additional attributes \(e.g. `1`\). | list | `<list>` | no |
| cloudtrail\_name | The name of the trail. | string | `"cloudtrail-multi-region"` | no |
| cloudwatch\_logs\_group\_name | The name of CloudWatch Logs group to which CloudTrail events are delivered. | string | `"iam_role_name"` | no |
| cloudwatch\_logs\_retention\_in\_days | Number of days to retain logs for. CIS recommends 365 days.  Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely. | number | `"365"` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | string | `"-"` | no |
| enabled | The boolean flag whether this module is enabled or not. No resources are created when set to false. | bool | `"true"` | no |
| environment | Environment \(e.g. `prod`, `dev`, `staging`\). | string | `""` | no |
| filename | The path of directory of code. | string | `""` | no |
| iam\_role\_name | The name of the IAM Role to be used by CloudTrail to delivery logs to CloudWatch Logs group. | string | `"CloudTrail-CloudWatch-Delivery-Role"` | no |
| iam\_role\_policy\_name | The name of the IAM Role Policy to be used by CloudTrail to delivery logs to CloudWatch Logs group. | string | `"CloudTrail-CloudWatch-Delivery-Policy"` | no |
| is\_organization\_trail | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | bool | `"false"` | no |
| key\_arn | The arn of the KMS. | string | `""` | no |
| key\_deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | number | `"10"` | no |
| label\_order | Label order, e.g. `name`,`application`. | list | `<list>` | no |
| lambda\_enabled | Whether to create lambda for cloudtrail logs. | bool | `"true"` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | string | `"anmol@clouddrove.com"` | no |
| name | Name  \(e.g. `app` or `cluster`\). | string | `""` | no |
| s3\_bucket\_name | The name of the S3 bucket which will store configuration snapshots. | string | n/a | yes |
| s3\_key\_prefix | The prefix for the specified S3 bucket. | string | `""` | no |
| s3\_policy | Policy of s3.. | list | `<list>` | no |
| slack\_channel | Channel of slack. | string | `""` | no |
| slack\_webhook | Webhook of slack. | string | `""` | no |
| tags | Additional tags \(e.g. map\(`BusinessUnit`,`XYZ`\). | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | The Amazon Resource Name of the trail |
| cloudtrail\_home\_region | The region in which the trail was created. |
| cloudtrail\_id | The name of the trail |
| kms\_arn | The ARN of KMS key. |
| log\_group\_name | The CloudWatch Logs log group which stores CloudTrail events. |
| s3\_arn | The ARN of S3 bucket. |
| s3\_id | The Name of S3 bucket. |
| tags | A mapping of tags to assign to the resource. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system.

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-cloudtrail-baseline/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-cloudtrail-baseline)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
