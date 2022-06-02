terraform {
  required_version = ">= 0.13.7"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.70.0"
    }
  }
}

// Search image
 data "yandex_compute_image" "my_image" {
 family = var.instance_family_image
 }

// Create instance
resource "yandex_compute_instance" "vm" {
  name        = var.instance_name
  platform_id = "standard-v1"
  zone        = var.instance_zone
  service_account_id = var.instance_service_account_id
  allow_stopping_for_update = true

/*
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install ansible"]

  }

*/

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
#      image_id = data.yandex_compute_image.my_image.id
      image_id = var.instance_image_id
      size = 40
    }
  }

  network_interface {
    subnet_id = var.instance_subnet_id
    nat = true
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("/mnt/c/#Work/#Sites/02-HMCIS/YaCloud/Certs/iaprokhorov_yacloud.pub")}"

  }
}
