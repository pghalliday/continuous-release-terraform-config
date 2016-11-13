output "jenkins" {
  value = "${aws_ecr_repository.jenkins.repository_url}"
}

output "jenkins-data" {
  value = "${aws_ecr_repository.jenkins-data.repository_url}"
}
