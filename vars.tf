variable "profile" {
  description = "profile name to get valid credentials of account"
}

variable "peer_profile" {
  description = "profile name of the accepter account"
  default = ""
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "ap-south-1"
}

variable "peer_region" {
  description = "AWS Region for the peer account"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "peer_availability_zones" {
  description = "List of availability zones of accepter account"
  type        = "list"
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "accepter_subnet_tags" {
  description = "list of subnets for which vpc peering to be done"
  type        = "list"
  default = []
}

variable "requester_subnet_tags" {
  type = "list"
  default = []
}

variable "accepter_external_peering_details" {
  type = "map"
  description = "map to get details of accepter like account id, vpc id, subnet cidrs to whitelist in requester for external peering"

  default = {
    account = ""
    vpc_id = ""
    subnet_cidrs = "0.0.0.0/0"
  }
}

variable "custom_tags" {
  type        = "map"
  default     = {}
  description = "map of tags to be added"
}

variable "requester_vpc_tags" {
  type        = "map"
  description = "Requestor VPC tags"
}

variable "accepter_vpc_tags" {
  type        = "map"
  description = "Acceptor VPC tags"
  default     = {}
}

variable "auto_accept" {
  description = "Accept peering request too (Peer account must be managed by Terraform)"
}

variable "peering_name" {
  default = ""
}

variable "requester_route_complete_vpc" {
  default = "true"
  description = "Route requester's vpc range in accepter route tables and also add accepter's CIDR in all subnets of requester"
}

variable "accepter_route_complete_vpc" {
  default = "true"
  description = "Route accepter's vpc range in requester route tables and also add requester's CIDR in all subnets of accepter"
}
