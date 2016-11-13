output "security_group_id" {
  value = "${aws_security_group.security_group.id}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}
