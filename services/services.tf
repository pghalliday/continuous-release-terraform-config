provider "aws" {
  region = "${var.aws_region}"
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

data "template_file" "jenkins" {
  template = "${file("${path.module}/jenkins.json.tpl")}"
  vars {
    jenkins_url = "${data.terraform_remote_state.repositories.jenkins}"
    jenkins_data_url = "${data.terraform_remote_state.repositories.jenkins-data}"
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  family = "jenkins"
  container_definitions = "${data.template_file.jenkins.rendered}"
}

resource "aws_ecs_service" "jenkins" {
  name = "jenkins"
  cluster = "${data.terraform_remote_state.cluster.cluster_id}"
  task_definition = "${aws_ecs_task_definition.jenkins.arn}"
  desired_count = 1
}

resource "aws_security_group_rule" "http" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${data.terraform_remote_state.cluster.security_group_id}"
}

resource "aws_security_group_rule" "jnlp" {
    type = "ingress"
    from_port = 50000
    to_port = 50000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${data.terraform_remote_state.cluster.security_group_id}"
}
