output "instance_vm_public_ip" {
  description = "instance vm1 public ip"
  value       = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}

output "instance_vm_ip" {
  description = "instance vm1 public ip"
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
}

