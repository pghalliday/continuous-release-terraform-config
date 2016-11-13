provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "network" {
	backend = "s3"
	config {
		bucket = "${var.aws_s3_bucket}"
		key = "${var.aws_s3_network_key}"
    region = "${var.aws_region}"
    encrypt = true
    kms_key_id = "${var.aws_kms_key_id}"
	}
}

data "terraform_remote_state" "cluster" {
	backend = "s3"
	config {
		bucket = "${var.aws_s3_bucket}"
		key = "${var.aws_s3_cluster_key}"
    region = "${var.aws_region}"
    encrypt = true
    kms_key_id = "${var.aws_kms_key_id}"
	}
}

data "terraform_remote_state" "repositories" {
	backend = "s3"
	config {
		bucket = "${var.aws_s3_bucket}"
		key = "${var.aws_s3_repositories_key}"
    region = "${var.aws_region}"
    encrypt = true
    kms_key_id = "${var.aws_kms_key_id}"
	}
}
