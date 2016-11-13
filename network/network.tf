provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "r" {
  route_table_id = "${aws_route_table.rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

resource "aws_subnet" "a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.a.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_subnet" "b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "b" {
  subnet_id = "${aws_subnet.b.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_subnet" "c" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.aws_region}c"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "c" {
  subnet_id = "${aws_subnet.c.id}"
  route_table_id = "${aws_route_table.rt.id}"
}
