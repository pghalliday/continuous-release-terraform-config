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

resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster_name}"
}

resource "aws_iam_role" "role" {
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role = "${aws_iam_role.role.id}"
  policy_arn = "${var.ecs_role_policy}"
}

resource "aws_iam_instance_profile" "profile" {
  roles = ["${aws_iam_role.role.id}"]
}

resource "aws_security_group" "security_group" {
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
}

resource "aws_security_group_rule" "ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "egress_all" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.security_group.id}"
}

data "template_file" "consul" {
  template = "${file("${path.module}/consul.tpl")}"
  vars {}
}

resource "aws_ecs_task_definition" "consul" {
  family = "consul"
  container_definitions = "${data.template_file.consul.rendered}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"
  vars {
    cluster_name = "${var.cluster_name}"
    aws_region = "${var.aws_region}"
    task_definition = "consul:${aws_ecs_task_definition.consul.revision}"
  }
}

resource "aws_launch_configuration" "lc" {
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ec2_key_pair}"
  security_groups = ["${aws_security_group.security_group.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group" {
  vpc_zone_identifier = [
    "${data.terraform_remote_state.network.subnet_a_id}",
    "${data.terraform_remote_state.network.subnet_b_id}",
    "${data.terraform_remote_state.network.subnet_c_id}"
  ]
  max_size = 5
  min_size = 3
  desired_capacity = 4
  launch_configuration = "${aws_launch_configuration.lc.id}"
}
