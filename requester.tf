
provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.profile}"
}

provider "aws" {
  alias   = "peer"
  region  = "${var.peer_region}"
  profile = "${var.peer_profile}"
}

/**
 * module to manage internal vpc peering request, where both the VPCs are managed by same terraform
 */

resource "aws_vpc_peering_connection" "internal" {
  peer_owner_id = "${data.aws_vpc.peer.owner_id}"
  peer_vpc_id   = "${data.aws_vpc.peer.id}"
  vpc_id        = "${data.aws_vpc.requester.id}"
  peer_region   = "${var.peer_region}"

  count = "${var.auto_accept == "true" ? 1 : 0}"

  tags = "${merge(
    map("Name", "${var.peering_name}"),
    var.custom_tags)
  }"
}

/**
 * module to manage external vpc peering request where request is in your control and peer account is managed by separate team
 */

resource "aws_vpc_peering_connection" "external" {
  peer_owner_id = "${var.accepter_external_peering_details["account"]}"
  peer_vpc_id   = "${var.accepter_external_peering_details["vpc_id"]}"
  vpc_id        = "${data.aws_vpc.requester.id}"
  peer_region   = "${var.peer_region}"

  count         = "${var.auto_accept == "false" ? 1 : 0}"

  tags = "${merge(
    map("Name", "${var.peering_name}"),
    var.custom_tags)
  }"
}

/**
 * routing of internal vpc peering requester, with all the routes tables of requester as well as accepter
 */

resource "aws_route" "internal_peering_with_requester_accepter_complete_vpc_routes" {
  route_table_id            = "${data.aws_route_tables.requester_all_rts.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.peer.cidr_block_associations.0.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.requester_route_complete_vpc == "true" && var.accepter_route_complete_vpc == "true" ? length(data.aws_route_tables.requester_all_rts.ids) : 0}"
}

/**
 * routing of internal vpc peering requester, with all the routes tables of requester and limited routes of accepter
 */

resource "aws_route" "internal_peering_with_requester_complete_vpc_accepter_limited_routes" {
  route_table_id            = "${data.aws_route_tables.requester_all_rts.ids[floor(count.index/(length(var.availability_zones) * length(var.accepter_subnet_tags)))]}"
  destination_cidr_block    = "${data.aws_subnet.accepter.*.cidr_block[count.index % (length(var.availability_zones) * length(var.accepter_subnet_tags))]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.requester_route_complete_vpc == "true" && var.accepter_route_complete_vpc == "false" ? length(data.aws_route_tables.requester_all_rts.ids) * length(var.availability_zones) * length(var.accepter_subnet_tags) : 0}"
}

/**
 * routing of internal vpc peering requester, with listed route tables of requester and all routes of accepter
 */

resource "aws_route" "internal_peering_with_requester_limited_accepter_complete_vpc_routes" {
  route_table_id            = "${data.aws_route_table.requester.*.id[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.peer.cidr_block_associations.0.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.requester_route_complete_vpc == "false" && var.accepter_route_complete_vpc == "true" ? length(var.availability_zones) * length(var.requester_subnet_tags) : 0}"
}

/**
 * routing of internal vpc peering requester, with listed route tables of requester and limited routes of accepter
 */

resource "aws_route" "internal_peering_with_requester_accepter_limited_routes" {
  route_table_id            = "${data.aws_route_table.requester.*.id[floor(count.index/(length(var.availability_zones) * length(var.accepter_subnet_tags)))]}"
  destination_cidr_block    = "${data.aws_subnet.accepter.*.cidr_block[count.index % (length(var.availability_zones) * length(var.accepter_subnet_tags))]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal.id}"

  count = "${var.auto_accept == "true" && var.requester_route_complete_vpc == "false" && var.accepter_route_complete_vpc == "false" ? length(var.availability_zones) * length(var.requester_subnet_tags) * length(var.accepter_subnet_tags) * length(var.availability_zones) : 0}"
}


/**
 * routing of external vpc peering requester, with all the routes tables of requester
 */

resource "aws_route" "external_peering_with_requester_complete_vpc_routes" {
  route_table_id            = "${data.aws_route_tables.requester_all_rts.ids[count.index]}"
  destination_cidr_block    = "${var.accepter_external_peering_details["subnet_cidrs"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.external.id}"

  count = "${var.auto_accept == "false" && var.requester_route_complete_vpc == "true" ? length(data.aws_route_tables.requester_all_rts.ids) : 0}"
}

/**
 * routing of external vpc peering requester, with listed route tables of requester
 */

resource "aws_route" "external_peering_with_requester_limited_routes" {
  route_table_id            = "${data.aws_route_table.requester.*.id[count.index]}"
  destination_cidr_block    = "${var.accepter_external_peering_details["subnet_cidrs"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.external.id}"

  count = "${var.auto_accept == "false" && var.requester_route_complete_vpc == "false" ? length(var.availability_zones) * length(var.requester_subnet_tags) : 0}"
}
