output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet_a_id" {
  value = "${aws_subnet.a.id}"
}

output "subnet_b_id" {
  value = "${aws_subnet.b.id}"
}

output "subnet_c_id" {
  value = "${aws_subnet.c.id}"
}
