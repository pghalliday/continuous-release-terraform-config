variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_s3_bucket" {
  default = "continuous-release-terraform"
}

variable "aws_s3_network_key" {
  default = "network/terraform.tfstate"
}

variable "aws_kms_key_id" {
  default = "arn:aws:kms:eu-west-1:735561797792:key/1370ee9f-0821-4035-8524-909190defc7e"
}

variable "ec2_key_pair" {
  default = "continuous-release-terraform"
}

variable "cluster_name" {
  default = "continuous_release"
}

variable "image_id" {
  default = "ami-c8337dbb"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ecs_role_policy" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
