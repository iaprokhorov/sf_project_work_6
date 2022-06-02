terraform {
  required_version = ">= 0.13.7"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.70.0"
    }
  }
}

// Create VPC
resource "yandex_vpc_network" "network" {
  name = "network"
}

// Create subnet 1
resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = var.zone_1
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

// Create subnet 2
resource "yandex_vpc_subnet" "subnet2" {
  name           = "subnet2"
  zone           = var.zone_2
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}

