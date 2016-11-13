variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_s3_bucket" {
  default = "continuous-release-terraform"
}

variable "aws_s3_cluster_key" {
  default = "cluster/terraform.tfstate"
}

variable "aws_s3_repositories_key" {
  default = "repositories/terraform.tfstate"
}

variable "aws_kms_key_id" {
  default = "arn:aws:kms:eu-west-1:735561797792:key/1370ee9f-0821-4035-8524-909190defc7e"
}
