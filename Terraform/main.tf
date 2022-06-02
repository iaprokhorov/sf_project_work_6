terraform {
  required_version = ">= 0.13.7"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.70.0"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "sf-bucket-3412"
    region     = "ru-central1"
    key        = "sf_terraform/sf_terraform.tfstate" # how create folder???
    access_key = "YCAJEqDikzKC_1ARuhyvEAMDW"
    secret_key = "YCM3Gg9c5VYCFw-lrYVCiAxDsgoqChIF6z7mCyMC"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

// Configure the Yandex.Cloud provider
provider "yandex" {
  token = var.token
  #  service_account_key_file = "path_to_service_account_key_file"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone_1
}


// Create SA
resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = "tf-test-sa"
}
// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "sf-bucket-3412"
}

/*
locals {
  virtual_machines = {
    "vm1" = { vm_subnet = module.ya_network.subnet1_id, zone = var.zone_1 }
    "vm2" = { vm_subnet = module.ya_network.subnet2_id, zone = var.zone_2 }
  }
}
*/

// Create network
module "ya_network" {
  source = "/mnt/c/learn-terraform-docker-container/.terraform/modules/network"
}

/*
// Create load balancer
module "ya_balancer" {
  source = "/mnt/c/learn-terraform-docker-container/.terraform/modules/balancer"
  for_each           = local.virtual_machines
  instance_subnet_id = each.value.vm_subnet
}
*/

// Create load balancer target group

resource "yandex_lb_target_group" "lb_tg" {
  name      = "lb-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = module.ya_network.subnet1_id
    address   = module.ya_instance_1.instance_vm_ip
  }

  target {
    subnet_id = module.ya_network.subnet2_id
    address   = module.ya_instance_2.instance_vm_ip
  }
}


// Create network load balancer

 resource "yandex_lb_network_load_balancer" "load_balancer" {
  name = "network-load-balancer"

  listener {
    name = "lb-listener"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.lb_tg.id}"

    healthcheck {
      name = "http"
      interval = 2
      tcp_options {
        port = 80
      }
    }
  }
}

// Create instances #1
module "ya_instance_1" {
  source             = "/mnt/c/learn-terraform-docker-container/.terraform/modules/instance"
  instance_name        = "vm1"
  instance_zone        = var.zone_1
  instance_subnet_id = module.ya_network.subnet1_id
#  instance_image_id = var.instance_image_id_1
#  for_each           = local.virtual_machines
#  instance_name      = each.key
#  instance_subnet_id = each.value.vm_subnet
#  instance_zone      = each.value.zone

  instance_service_account_id = yandex_iam_service_account.sa.id
}

// Create instances #2
module "ya_instance_2" {
  source             = "/mnt/c/learn-terraform-docker-container/.terraform/modules/instance"
  instance_name        = "vm2"
  instance_zone        = var.zone_2
  instance_subnet_id = module.ya_network.subnet2_id
#  instance_image_id = "fd803lrp5ob4raaggfdk"
#  for_each           = local.virtual_machines
#  instance_name      = each.key
#  instance_subnet_id = each.value.vm_subnet
#  instance_zone      = each.value.zone

  instance_service_account_id = yandex_iam_service_account.sa.id
}






