data "aws_vpc" "requester" {
  tags  = "${var.requester_vpc_tags}"
}

data "aws_vpc" "peer" {
  provider = "aws.peer"
  tags  = "${var.accepter_vpc_tags}"
  count = "${var.auto_accept == "true" ? 1 : 0}"
}

data "aws_caller_identity" "peer" {
  provider = "aws.peer"
  count = "${var.auto_accept == "true" ? 1 : 0}"
}

data "aws_subnet" "requester" {
  vpc_id = "${data.aws_vpc.requester.id}"
  availability_zone = "${element(var.availability_zones,count.index)}"
  tags = "${var.requester_subnet_tags[floor(count.index/length(var.availability_zones))]}"

  count = "${length(var.availability_zones) * length(var.requester_subnet_tags)}"
}

data "aws_route_tables" "requester_all_rts" {
  vpc_id = "${data.aws_vpc.requester.id}"
  #count = "${var.requester_route_complete_vpc == "true" ? 1 : 0}"
}

data "aws_route_table" "requester" {
  subnet_id = "${data.aws_subnet.requester.*.id[count.index]}"

  count = "${length(var.availability_zones) * length(var.requester_subnet_tags)}"
}

data "aws_route_tables" "accepter_all_rts" {
  provider ="aws.peer"
  vpc_id = "${data.aws_vpc.peer.id}"
  count = "${var.auto_accept == "true" ? 1 : 0}"
}

data "aws_subnet" "accepter" {
  provider = "aws.peer"
  vpc_id = "${data.aws_vpc.peer.id}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  tags = "${var.accepter_subnet_tags[floor(count.index/length(var.availability_zones))]}"

  count = "${var.auto_accept == "true" && var.accepter_route_complete_vpc == "false" ? length(var.availability_zones) * length(var.accepter_subnet_tags) : 0}"
}

data "aws_route_table" "accepter" {
  provider = "aws.peer"
  subnet_id = "${data.aws_subnet.accepter.*.id[count.index]}"

  count = "${var.auto_accept == "true" && var.accepter_route_complete_vpc == "false" ? length(var.availability_zones) * length(var.accepter_subnet_tags) : 0}"
}
