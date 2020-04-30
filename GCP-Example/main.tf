provider "google" {
  version     = ">= 3.15.0"
  credentials = file("../credentials.json")
}

provider "google-beta" {
  version     = ">= 3.15.0"
  credentials = file("../credentials.json")
}

# define path where to create folders

locals {
  root_path = "${var.parent_type}/${var.parent_id}"
}

#  create folders structure

resource "google_folder" "common" {
  display_name = "Common Services"
  parent       = local.root_path
}

resource "google_folder" "prod" {
  display_name = "Production"
  parent       = local.root_path
}

resource "google_folder" "dev" {
  display_name = "Developers"
  parent       = local.root_path
}

#  create host projects

module "common_host" {
  source            = "terraform-google-modules/project-factory/google"
  version           = ">= 7.1"
  random_project_id = true
  name              = var.common_host
  folder_id         = trimprefix(google_folder.common.id, "folders/")
  org_id            = var.org_id
  billing_account   = var.billing_account
}

module "prod_host" {
  source            = "terraform-google-modules/project-factory/google"
  version           = ">= 7.1"
  random_project_id = true
  name              = var.prod_host
  folder_id         = trimprefix(google_folder.prod.id, "folders/")
  org_id            = var.org_id
  billing_account   = var.billing_account
}

#  create shared VPCs

module "common_vpc" {
  source  = "terraform-google-modules/network/google"
  version = ">= 2.1"

  project_id   = module.common_host.project_id
  network_name = var.common_vpc

  delete_default_internet_gateway_routes = true
  shared_vpc_host                        = true

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "us-west1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "us-west2"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]
}

module "prod_vpc" {
  source  = "terraform-google-modules/network/google"
  version = ">= 2.1"

  project_id   = module.prod_host.project_id
  network_name = var.prod_vpc

  delete_default_internet_gateway_routes = true
  shared_vpc_host                        = true

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.20.10.0/24"
      subnet_region         = "us-west1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.20.20.0/24"
      subnet_region         = "us-west2"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]
}


#add firewall rules

resource "google_compute_firewall" "comm_fw_rule1" {
  name    = "allow-ssh-and-icmp"
  network = module.common_vpc.network_self_link
  project = module.common_host.project_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [22, 80, 443]
  }
}

resource "google_compute_firewall" "prod_fw_rule1" {
  name    = "allow-ssh-and-icmp"
  network = module.prod_vpc.network_self_link
  project = module.prod_host.project_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [22, 80, 443]
  }
}

# create and  attach service projects

module "common_service_1" {
  source  = "terraform-google-modules/project-factory/google//modules/shared_vpc"
  version = ">= 7.1.0"

  name              = var.common_service_1
  random_project_id = true

  org_id             = var.org_id
  folder_id          = trimprefix(google_folder.common.id, "folders/")
  billing_account    = var.billing_account
  shared_vpc_enabled = true

  shared_vpc         = module.common_vpc.project_id
  shared_vpc_subnets = module.common_vpc.subnets_self_links

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
  disable_services_on_destroy = false
}

module "prod_service_1" {
  source  = "terraform-google-modules/project-factory/google//modules/shared_vpc"
  version = ">= 7.1.0"

  name              = var.prod_service_1
  random_project_id = true

  org_id             = var.org_id
  folder_id          = trimprefix(google_folder.prod.id, "folders/")
  billing_account    = var.billing_account
  shared_vpc_enabled = true

  shared_vpc         = module.prod_vpc.project_id
  shared_vpc_subnets = module.prod_vpc.subnets_self_links

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
  disable_services_on_destroy = false
}

# establish VPC peering

module "comm_prod_peering" {
  source  = "terraform-google-modules/network/google//modules/network-peering"
  version = ">= 2.1.1"

  prefix        = "peering"
  local_network = module.common_vpc.network_self_link
  peer_network  = module.prod_vpc.network_self_link

}

