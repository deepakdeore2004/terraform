provider "aws" {
	region = "${var.aws_region}"
}

# Create vpc
resource "aws_vpc" "test" {
	cidr_block = "${var.env["cidr"]}"

	tags {
		Name = "${var.env["name"]}"
	}
}

# Create internet gateway for public subnets
resource "aws_internet_gateway" "test" {
    vpc_id = "${aws_vpc.test.id}"

    tags {
        Name = "${var.env["name"]}"
    }
}

# Create nat gateway for private subnets
resource "aws_nat_gateway" "test" {
	allocation_id = "${aws_eip.nat.id}"
	subnet_id = "${aws_subnet.public.0.id}"
}

# Create route table for public subnets
resource "aws_route_table" "test_public" {
    vpc_id = "${aws_vpc.test.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.test.id}"
    }

    tags {
        Name = "${var.env["name"]}_public"
    }
}

# Create route table for private subnets
resource "aws_route_table" "test_private" {
    vpc_id = "${aws_vpc.test.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.test.id}"
    }

    tags {
        Name = "${var.env["name"]}_private"
    }
}

# Create public subnets
resource "aws_subnet" "public" {
	vpc_id = "${aws_vpc.test.id}"
	cidr_block = "${lookup(var.public_cidr, format("zone%d", count.index))}"
	availability_zone = "${lookup(var.az, format("zone%d", count.index))}"
	count = "${var.env["number_of_public_subnets"]}"

	tags {
		Name = "${var.env["name"]}_public_${count.index}"
	}
}

# Create private subnets
resource "aws_subnet" "private" {
	vpc_id = "${aws_vpc.test.id}"
	cidr_block = "${lookup(var.private_cidr, format("zone%d", count.index))}"
	availability_zone = "${lookup(var.az, format("zone%d", count.index))}"
	count = "${var.env["number_of_private_subnets"]}"

	tags {
		Name = "${var.env["name"]}_private_${count.index}"
	}
}

# Create EIP for nat gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Set route table for public subnets
resource "aws_route_table_association" "public" {
	count = "${var.env["number_of_public_subnets"]}"
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
	route_table_id = "${aws_route_table.test_public.id}"
}

# Set route table for private subnets
resource "aws_route_table_association" "private" {
	count = "${var.env["number_of_private_subnets"]}"
	subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
	route_table_id = "${aws_route_table.test_private.id}"
}

# Manage default network acl
resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.test.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

	egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

	tags {
		Name = "${var.env["name"]}"
	}
}
