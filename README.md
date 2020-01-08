# AWS S3 Private Bucket Terraform Module

Terraform module which creates a *private* S3 bucket on AWS with compulsory features enabled
to enforce desired controls and liked features exposed through variables.

The following resources are supported:

* [S3 Bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
* [S3 Bucket Policy](https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html)

The following features are enabled and will be applied:

- server-side encryption
- access control _(must be private OR logging)_

The following features can be configured through variables:

- versioning _(enabled by default)_
- static web-site hosting
- access logging
- cross origin resource sharing (CORS)
- lifecycle rules
- server-side encryption
- object locking _(enabled by default)_
- cross region replication (CRR)

## S3 Bucket Policy

_TODO: Enhance the role and policy to incorporate other principals and whitelisting_

The S3 bucket policy has been defined.

The following actions can be performed

```
  s3:ListBucket
  s3:GetObject
  s3:PutObject
  s3:DeleteObject
]
```

by the following principals

```
  Service: ec2.amazonaws.com
```

## Example Usage

The following are examples that illustrate how the use the module
* [Complete](https://github.com/sverze/aws-terraform-s3-private-bucket/tree/master/src/main/terraform/examples/s3-complete) - Complete S3 bucket with most of supported features enabled
* [Cross-Region Replication](https://github.com/sverze/aws-terraform-s3-private-bucket/tree/master/src/main/terraform/examples/s3-replication) - S3 bucket with Cross-Region Replication (CRR) enabled

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acceleration\_status | Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended. | string | `"null"` | no |
| acl |  Must be 'private' or 'log-delivery-write'. Defaults to 'private'. | string | `"private"` | yes |
| attach\_elb\_log\_delivery\_policy | Controls if S3 bucket should have ELB log delivery policy attached | bool | `"false"` | no |
| bucket | The name of the bucket. If omitted, Terraform will assign a random, unique name. | string | `"null"` | no |
| bucket\_prefix | Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | string | `"null"` | no |
| cors\_rule | Map containing a rule of Cross-Origin Resource Sharing. | any | `{}` | no |
| force\_destroy | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | bool | `"false"` | no |
| kms_master_key_id | KMS key ARN, this is used to encrypt bucket objects for SSE | string |  | yes |
| lifecycle\_rule | List of maps containing configuration of object lifecycle management. | any | `[]` | no |
| logging | Map containing access bucket logging configuration. | map(string) | `{}` | no |
| object\_lock\_configuration | Map containing S3 object locking configuration. | any | `{}` | no |
| profile | The AWS profile to use to authenticate using the AWS API | string | "default" | yes |
| region | The AWS region this bucket should reside in | string | | yes |
| replication\_configuration | Map containing cross-region replication configuration. | any | `{}` | no |
| request\_payer |  Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information. | string | `"null"` | no |
| sse_algorithm | Server side encryption key algorithm used by the KMS master key | string | `aws:kms` | no |
| tags | A mapping of tags to assign to the bucket. | map(string) | `{}` | no |
| versioning | Map containing versioning configuration. | map(string) | `{}` | no |
| website | Map containing static web-site hosting or redirect configuration. | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_s3\_bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| this\_s3\_bucket\_bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| this\_s3\_bucket\_bucket\_regional\_domain\_name | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| this\_s3\_bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| this\_s3\_bucket\_id | The name of the bucket. |
| this\_s3\_bucket\_region | The AWS region this bucket resides in. |
| this\_s3\_bucket\_website\_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| this\_s3\_bucket\_website\_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |

## Testing

Terratest is used for integration testing of the bundles examples

### Install requirements

Terratest uses the Go testing framework, prerequisites to use Terratest install:

- [Terraform](https://www.terraform.io/) (requires version >=0.12)
- [Go](https://golang.org/) (requires version >=1.13)


### Setting up your project

The easiest way to get started with Terratest is to copy one of the examples and its corresponding tests from this
repo.

1. Clone this repository

1. Move to one of the test examples folders such as [s3_complete](/tests/terraform/examples/s3-somplete) directory

1. Configure the Go dependencies, run:

    ```bash
    cd test
    go mod init "<MODULE_NAME>"
    ```

    Where `<MODULE_NAME>` is the name of your module, typically in the format
    `<YOUR_REPO>/<YOUR_USERNAME>/<YOUR_REPO_NAME>`.
    For example `github.com/sverze/aws-terraform-s3-private-bucket/s3_complete`

1. To run the example tests:

    ```bash
    go test -v -timeout 5m
    ```

    *(See [Timeouts and logging](#timeouts-and-logging) for why the `-timeout` parameter is used.)*
