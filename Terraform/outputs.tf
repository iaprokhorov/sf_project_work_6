/*
output "access_key" {
  description = "Bucket access_key in yandex cloud"
  sensitive   = true
  value       = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}
output "secret_key" {
  description = "Bucket access_key in yandex cloud"
  sensitive   = true
  value       = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

*/

output "instance_vm1_public_ip" {
  description = "IP instance in yandex cloud"
  value       = module.ya_instance_1.instance_vm_public_ip
}

output "instance_vm2_public_ip" {
  description = "IP instance in yandex cloud"
  value       = module.ya_instance_2.instance_vm_public_ip
}

output "instance_vm3_public_ip" {
  description = "IP instance in yandex cloud"
  value       = module.ya_instance_3.instance_vm_public_ip
}
