provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_ecr_repository" "jenkins" {
  name = "jenkins"
}

resource "aws_ecr_repository" "jenkins_data" {
  name = "jenkins-data"
}
