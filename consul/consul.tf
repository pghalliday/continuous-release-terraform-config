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

resource "aws_iam_policy" "policy" {
    name = "consul_server_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role = "${aws_iam_role.role.id}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "profile" {
  roles = ["${aws_iam_role.role.id}"]
}

resource "aws_security_group" "elb_security_group" {
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
}

resource "aws_security_group" "security_group" {
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
}

resource "aws_security_group_rule" "elb_http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.elb_security_group.id}"
}

resource "aws_security_group_rule" "elb_egress" {
    type = "egress"
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.security_group.id}"
    security_group_id = "${aws_security_group.elb_security_group.id}"
}

resource "aws_security_group_rule" "ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "rpc" {
    type = "ingress"
    from_port = 8300
    to_port = 8300
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.security_group.id}"
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "http" {
    type = "ingress"
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.elb_security_group.id}"
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "http_test" {
    type = "ingress"
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.security_group.id}"
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "lan_gossip_tcp" {
    type = "ingress"
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.security_group.id}"
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "lan_gossip_udp" {
    type = "ingress"
    from_port = 8301
    to_port = 8301
    protocol = "udp"
    source_security_group_id = "${aws_security_group.security_group.id}"
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "dns_tcp" {
    type = "ingress"
    from_port = 8600
    to_port = 8600
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.security_group.id}"
    security_group_id = "${aws_security_group.security_group.id}"
}

resource "aws_security_group_rule" "dns_udp" {
    type = "ingress"
    from_port = 8600
    to_port = 8600
    protocol = "udp"
    source_security_group_id = "${aws_security_group.security_group.id}"
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

resource "aws_elb" "elb" {
  subnets = [
    "${data.terraform_remote_state.network.subnet_public_a_id}",
    "${data.terraform_remote_state.network.subnet_public_b_id}",
    "${data.terraform_remote_state.network.subnet_public_c_id}"
  ]
  security_groups = ["${aws_security_group.elb_security_group.id}"]

  listener {
    instance_port = 8500
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8500/ui/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"
  vars {
    cluster_name = "${var.cluster_name}"
    ec2_tag_key = "${var.ec2_tag_key}"
    ec2_tag_value = "${var.ec2_tag_value}"
    bootstrap_expect = "3"
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
    "${data.terraform_remote_state.network.subnet_public_a_id}",
    "${data.terraform_remote_state.network.subnet_public_b_id}",
    "${data.terraform_remote_state.network.subnet_public_c_id}"
  ]
  max_size = 7
  min_size = 3
  desired_capacity = 5
  launch_configuration = "${aws_launch_configuration.lc.id}"
  load_balancers = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"

  tag {
    key = "${var.ec2_tag_key}"
    value = "${var.ec2_tag_value}"
    propagate_at_launch = true
  }
}
