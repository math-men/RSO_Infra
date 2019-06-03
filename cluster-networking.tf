data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "172.17.0.0/16"
}

resource "aws_subnet" "public" {
  count                   = "2"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-sshort ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "sshort-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route_table_association" "public" {
  count     = "2"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

