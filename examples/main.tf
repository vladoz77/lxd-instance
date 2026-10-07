terraform {
  required_version = ">= 1.3"

  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 3.0"
    }
  }
}


resource "lxd_storage_pool" "example" {
  name   = "example-pool"
  driver = "dir"
}

resource "lxd_network" "example" {
  name = "example-br"

  config = {
    "ipv4.address" = "10.99.0.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "none"
  }
}

provider "lxd" {
  remote {
    name                           = "example"
    address                        = var.lxd_server_address
    server_certificate_fingerprint = var.lxd_server_cert_fingerprint
    client_certificate_file        = pathexpand(var.lxd_client_cert_file)
    client_key_file                = pathexpand(var.lxd_client_key_file)
  }
}

module "instance" {
  source = "../"   

  network_name = lxd_network.example.name

  instance = {
    name           = "example-vm"
    image          = var.image
    cpu            = 1
    memory         = "1GiB"
    root_disk_pool = lxd_storage_pool.example.name
    # ipv4_address и cloud_init не заданы: DHCP, без cloud-init
  }
}

output "instance_name" {
  value = module.instance.instance_name
}