provider "aws" {
  region = "${var.aws_region}"
}

data "template_file" "jenkins" {
  template = "${file("${path.module}/docker.tpl")}"
  vars {
    aws_region = "${var.aws_region}"
    container = "jenkins"
  }
}

resource "aws_ecr_repository" "jenkins" {
  name = "jenkins"
  provisioner "local-exec" {
    command = "${replace(data.template_file.jenkins.rendered, "__REPOSITORY__", replace(aws_ecr_repository.jenkins.repository_url, "https://", ""))}"
  }
}

data "template_file" "jenkins-data" {
  template = "${file("${path.module}/docker.tpl")}"
  vars {
    aws_region = "${var.aws_region}"
    container = "jenkins-data"
  }
}

resource "aws_ecr_repository" "jenkins-data" {
  name = "jenkins-data"
  provisioner "local-exec" {
    command = "${replace(data.template_file.jenkins-data.rendered, "__REPOSITORY__", replace(aws_ecr_repository.jenkins-data.repository_url, "https://", ""))}"
  }
}
