# Terraform AWS VPC Peering Module
This is Terraform module to create AWS VPC Peering with auto acceptance and route entries. It supports various usecases:

* Peering between VPCs in two separate AWS accounts, both managed by same team using Terraform.
* Peering between VPCs in two separate AWS accounts, where requester VPC is managed by Terraform but accepter VPC is not.
* Peering between VPCs in same account.

**This module requires Terraform v0.11.**

Following are different usage examples of this module with required variables for it.

#### VPCs in separate/same AWS accounts in same region, both managed by same team using Terraform. Route complete VPC CIDR on both sides

```hcl
module "vpc_peering" {
  source = "github.com/SanchitBansal/terraform-aws-vpc-peering.git?ref=master"

  profile = "nonprod"
  peer_profile = "prod"
  peer_region = "ap-south-1"

  requester_vpc_tags = {
    environment = "test"
  }

  accepter_vpc_tags = {
    environment = "prod"
  }
  requester_route_complete_vpc = "true"
  accepter_route_complete_vpc = "true"
  peering_name = "Peering between test and prod VPC"

  custom_tags = {
    businessunit = "techteam"
    organization "github"
  }

  auto_accept = "true"
```

#### VPCs in separate/same AWS accounts in same region, both managed by same team using Terraform. Connect complete VPC of requester with specific subnet of accepter

```hcl
module "vpc_peering" {
  source = "github.com/SanchitBansal/terraform-aws-vpc-peering.git?ref=master"

  profile = "nonprod"
  peer_profile = "prod"
  peer_region = "ap-south-1"

  requester_vpc_tags = {
    environment = "test"
  }

  accepter_vpc_tags = {
    environment = "prod"
  }

  requester_route_complete_vpc = "true"
  accepter_route_complete_vpc = "false"

  accepter_subnet_tags = [
    {
      environment = "prod"
      role = "infra"
    },
    {
      environment = "prod"
      role = "db"
    }
  ]

  custom_tags = {
    businessunit = "techteam"
    organization "github"
  }

  peering_name = "Peering between test and prod VPC"
  auto_accept = "true"
```

#### VPCs in separate/same AWS accounts in same region, both managed by same team using Terraform. Connect specific subnet of requester with complete VPC of accepter

```hcl
module "vpc_peering" {
  source = "github.com/SanchitBansal/terraform-aws-vpc-peering.git?ref=master"

  profile = "nonprod"
  peer_profile = "prod"
  peer_region = "ap-south-1"

  requester_vpc_tags = {
    environment = "test"
  }

  accepter_vpc_tags = {
    environment = "prod"
  }

  requester_route_complete_vpc = "false"
  accepter_route_complete_vpc = "true"

  requester_subnet_tags = [
    {
      environment = "test"
      role = "app"
    },
    {
      environment = "test"
      role = "infra"
    }
  ]

  custom_tags = {
    businessunit = "techteam"
    organization "github"
  }

  peering_name = "Peering between test and prod VPC"
  auto_accept = "true"
```

#### VPCs in separate/same AWS accounts in same region, both managed by same team using Terraform. Connect specific subnet of requester with specific subnet of accepter

```hcl
module "vpc_peering" {
  source = "github.com/SanchitBansal/terraform-aws-vpc-peering.git?ref=master"

  profile = "nonprod"
  peer_profile = "prod"
  peer_region = "ap-south-1"

  requester_vpc_tags = {
    environment = "test"
  }

  accepter_vpc_tags = {
    environment = "prod"
  }

  requester_route_complete_vpc = "false"
  accepter_route_complete_vpc = "false"

  requester_subnet_tags = [
    {
      environment = "test"
      role = "app"
    },
    {
      environment = "test"
      role = "infra"
    }
  ]

  accepter_subnet_tags = [
    {
      environment = "prod"
      role = "infra"
    },
    {
      environment = "prod"
      role = "db"
    }
  ]

  custom_tags = {
    businessunit = "techteam"
    organization "github"
  }

  peering_name = "Peering between test and prod VPC"
  auto_accept = "true"
```

#### VPCs in separate AWS accounts in same/different region, where only requester VPC is managed using Terraform. Connect specific subnet of requester with accepter

```hcl
module "vpc_peering" {
  source = "github.com/SanchitBansal/terraform-aws-vpc-peering.git?ref=master"

  profile = "nonprod"
  peer_region = "ap-southeast-1"

  requester_vpc_tags = {
    environment = "test"
  }

  requester_route_complete_vpc = "false"

  requester_subnet_tags = [
    {
      environment = "test"
      role = "app"
    },
    {
      environment = "test"
      role = "infra"
    }
  ]

  accepter_external_peering_details = {
    account = "57xxxxxxxxxx"
    vpc_id = "vpc-xxxxxx"
    subnet_cidrs = "192.168.0.0/21"
  }

  custom_tags = {
    businessunit = "techteam"
    organization "github"
  }

  peering_name = "Peering between test and prod VPC"
  auto_accept = "false"
```

I have many other [Terraform modules](https://github.com/SanchitBansal?tab=repositories&q=terraform&type=&language=) that are open source. Check them out!

**I will keep enhancing it if found any issues or any feature request from your side**
