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
#  role      = "storage.editor"
  role      = "admin"
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
    "vm2" = { vm_subnet = module.ya_network.subnet1_id, zone = var.zone_1 }
  }
}
*/

// Create network
module "ya_network" {
  source = "/mnt/c/Projects/sf_project_work_6/terraform/modules/network"
}


// Create instances #1
module "ya_instance_1" {
  source            = "/mnt/c/Projects/sf_project_work_6/terraform/modules/instance"
  instance_name     = "vm1"
  instance_zone     = var.zone_1
  instance_image_id = "fd89ovh4ticpo40dkbvd"
  instance_subnet_id = module.ya_network.subnet1_id
  #  for_each           = local.virtual_machines
  #  instance_name      = each.key
  #instance_subnet_id = each.value.vm_subnet
  #  instance_zone      = each.value.zone

  instance_service_account_id = yandex_iam_service_account.sa.id
}

// Create instances #2
module "ya_instance_2" {
  source             = "/mnt/c/Projects/sf_project_work_6/terraform/modules/instance"
  instance_name      = "vm2"
  instance_zone      = var.zone_1
  instance_image_id  = "fd89ovh4ticpo40dkbvd"
  instance_subnet_id = module.ya_network.subnet1_id
  #  for_each           = local.virtual_machines
  #  instance_name      = each.key
#  instance_subnet_id = each.value.vm_subnet
  #  instance_zone      = each.value.zone

  instance_service_account_id = yandex_iam_service_account.sa.id
}

// Create instances #3
module "ya_instance_3" {
  source            = "/mnt/c/Projects/sf_project_work_6/terraform/modules/instance"
  instance_name     = "vm3"
  instance_zone     = var.zone_1
  instance_image_id = "fd8hqa9gq1d59afqonsf"
  instance_subnet_id = module.ya_network.subnet1_id
  #  for_each           = local.virtual_machines
  #  instance_name      = each.key
#  instance_subnet_id = each.value.vm_subnet
  #  instance_zone      = each.value.zone

  instance_service_account_id = yandex_iam_service_account.sa.id
}





