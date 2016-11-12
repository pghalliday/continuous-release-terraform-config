output "jenkins" {
  value = "${aws_ecr_repository.jenkins.repository_url}"
}

output "jenkins_data" {
  value = "${aws_ecr_repository.jenkins_data.repository_url}"
}
