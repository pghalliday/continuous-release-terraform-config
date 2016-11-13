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

resource "aws_iam_role_policy_attachment" "test-attach" {
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

resource "aws_launch_configuration" "lc" {
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ec2_key_pair}"
  security_groups = ["${aws_security_group.security_group.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
EOF

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
  max_size = 4
  min_size = 2
  desired_capacity = 3
  launch_configuration = "${aws_launch_configuration.lc.id}"
}
