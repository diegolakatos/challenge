resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  instance_tenancy     = "default"

  tags {
    name = "${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = ["aws_vpc.vpc"]
}

data "aws_availability_zones" "all" {}

resource "aws_subnet" "private_subnets" {
  map_public_ip_on_launch = false
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${var.subnet_count}"
  cidr_block              = "${cidrsubnet(var.cidr_block, var.cidr_network_bits, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.all.names, count.index)}"

  tags {
    Name = "private-${element(data.aws_availability_zones.all.names, count.index)}-subnet"
  }
}

resource "aws_subnet" "public_subnets" {
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${var.subnet_count}"
  cidr_block              = "${cidrsubnet(var.cidr_block, var.cidr_network_bits, (count.index + length(data.aws_availability_zones.all.names)))}"
  availability_zone       = "${element(data.aws_availability_zones.all.names, count.index)}"

  tags {
    Name = "public-${element(data.aws_availability_zones.all.names, count.index)}-subnet"
  }
}

resource "aws_eip" "nat_gateway_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_gateway_eip.id}"
  subnet_id     = "${aws_subnet.public_subnets.*.id[0]}"
  depends_on    = ["aws_internet_gateway.internet_gateway", "aws_subnet.public_subnets"]
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags {
    Name = "route_table_public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  tags {
    Name = "route_table_private"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private_assoc" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id,count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route53_zone" "internal_zone" {
  name = "${var.zone_name}.internal"

  vpc {
    vpc_id = "${aws_vpc.vpc.id}"
  }
}

resource "aws_security_group" "vpc_security_group" {
  name   = "aws-${var.vpc_name}-vpc-sg"
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "allow_ssh_internal" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.cidr_block}"]

  security_group_id = "${aws_security_group.vpc_security_group.id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vpc_security_group.id}"
}
