# continuous-release-terraform-config

## Dependencies

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- An AWS account with access key id, secret key and full admin permissions

Configure an AWS CLI profile using

```
aws configure --profile crt
```

## Prerequisites

The following have been pre-created though the AWS console

- A KMS key for encrypting remote terraform states
  - `arn:aws:kms:eu-west-1:735561797792:key/1370ee9f-0821-4035-8524-909190defc7e`
- An S3 bucket to remotely store terraform states
  - `continuous-release-terraform`
- An EC2 key pair to log in to instances
  - `continuous-release-terraform`

## Layers

- network - VPC, etc
- cluster - ECS Cluster config and autoscaling group
- repositories - ECS Storage for docker images
- docker config - Build and push to repositories
- services - ECS Task definitions and services to deploy on cluster

Configured and deployed separately in this order to allow for migration to other buckets/network config/cluster/repositories later
