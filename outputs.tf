# outputs.tf
output "instance_name" {
  value = lxd_instance.instance.name
}

output "ipv4_address" {
  value = lxd_instance.instance.ipv4_address
}

output "volumes" {
  value = { for k, v in lxd_storage_volume.volumes : k => {
    name = v.name
    pool = v.pool
    size = v.config.size
  } }
}