/**
 * module to manage vpc peering acceptance
 */

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"
  auto_accept               = true

  count = "${var.auto_accept == "true" ? 1 : 0}"

  tags = "${merge(
    map("Name", "${var.peering_name}"),
    var.custom_tags)
  }"
}

/**
 * routing of internal vpc peering accepter, with all the routes tables of requester as well as accepter
 */

resource "aws_route" "internal_peering_with_accepter_requester_complete_vpc_routes" {
  provider                  = "aws.peer"
  route_table_id            = "${data.aws_route_tables.accepter_all_rts.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.requester.cidr_block_associations.0.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.requester_route_complete_vpc == "true" && var.accepter_route_complete_vpc == "true" ? length(data.aws_route_tables.accepter_all_rts.ids) : 0}"
}

/**
 * routing of internal vpc peering accepter, with all the routes tables of accepter and limited routes of requester
 */

resource "aws_route" "internal_peering_with_accepter_complete_vpc_requester_limited_routes" {
  provider                  = "aws.peer"
  route_table_id            = "${data.aws_route_tables.accepter_all_rts.ids[floor(count.index/(length(var.availability_zones) * length(var.requester_subnet_tags)))]}"
  destination_cidr_block    = "${data.aws_subnet.requester.*.cidr_block[count.index % (length(var.availability_zones) * length(var.requester_subnet_tags))]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.accepter_route_complete_vpc == "true" && var.requester_route_complete_vpc == "false" ? length(data.aws_route_tables.accepter_all_rts.ids) * length(var.requester_subnet_tags) * length(var.availability_zones) : 0}"
}

/**
 * routing of internal vpc peering accepter, with listed route tables of accepter and all routes of requester
 */

resource "aws_route" "internal_peering_with_accepter_limted_requester_complete_vpc_routes" {
  provider                  = "aws.peer"
  route_table_id            = "${data.aws_route_table.accepter.*.id[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.requester.cidr_block_associations.0.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.accepter_route_complete_vpc == "false" && var.requester_route_complete_vpc == "true" ? length(var.peer_availability_zones) * length(var.accepter_subnet_tags) : 0}"
}

/**
 * routing of internal vpc peering accepter, with listed route tables of both accepter and requester
 */

resource "aws_route" "internal_peering_with_accepter_requester_limited_routes" {
  provider                  = "aws.peer"
  route_table_id            = "${data.aws_route_table.accepter.*.id[count.index/(length(var.availability_zones) * length(var.requester_subnet_tags))]}"
  destination_cidr_block    = "${data.aws_subnet.requester.*.cidr_block[count.index % (length(var.availability_zones) * length(var.requester_subnet_tags))]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.accepter_route_complete_vpc == "false" && var.requester_route_complete_vpc == "false" ? length(var.peer_availability_zones) * length(var.accepter_subnet_tags) * length(var.availability_zones) * length(var.requester_subnet_tags) : 0}"
}
