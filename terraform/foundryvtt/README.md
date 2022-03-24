<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.74.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.foundry_bucket_profile](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.foundry_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.foundry_attach](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.ec2_s3_access_role](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_role) | resource |
| [aws_instance.foundry_instance](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/instance) | resource |
| [aws_lb.foundry](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/lb) | resource |
| [aws_lb_listener.foundry](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.foundry](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.foundry](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.foundry](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.foundry](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/route53_record) | resource |
| [aws_acm_certificate.issued](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/acm_certificate) | data source |
| [aws_ami.linux2_ami](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | n/a | `string` | `"medgelabs-foundry"` | no |
| <a name="input_foundry_dns_name"></a> [foundry\_dns\_name](#input\_foundry\_dns\_name) | n/a | `string` | `"foundry.medgelabs.io"` | no |
| <a name="input_r53_zone_id"></a> [r53\_zone\_id](#input\_r53\_zone\_id) | n/a | `string` | `"Z1IKIK8GNXT5E9"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | foundry tag name | `string` | `"FoundryVTT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_foundry_load_balancer_dns"></a> [foundry\_load\_balancer\_dns](#output\_foundry\_load\_balancer\_dns) | n/a |
| <a name="output_instance_ip_addr"></a> [instance\_ip\_addr](#output\_instance\_ip\_addr) | n/a |
| <a name="output_instance_key_name"></a> [instance\_key\_name](#output\_instance\_key\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
