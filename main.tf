# main.tf
resource "lxd_storage_volume" "volumes" {
  for_each = var.volumes

  name         = "${var.instance.name}-${each.key}"
  pool         = each.value.pool
  content_type = "block"

  config = {
    size = each.value.size
  }
}

resource "lxd_instance" "instance" {
  name      = var.instance.name
  image     = var.instance.image
  type      = "virtual-machine"
  profiles  = var.profiles
  ephemeral = false

  config = merge(
    {
      "limits.cpu"    = tostring(var.instance.cpu)
      "limits.memory" = var.instance.memory
    },
    var.instance.cloud_init == null ? {} : { "cloud-init.user-data" = var.instance.cloud_init }
  )

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.instance.root_disk_pool
      size = var.instance.root_disk_size
    }
  }

  device {
    name = "cloud-init"
    type = "disk"
    properties = {
      source = "cloud-init:config"
    }
  }

  dynamic "device" {
    for_each = var.volumes

    content {
      name = device.key
      type = "disk"
      properties = {
        pool   = device.value.pool
        source = lxd_storage_volume.volumes[device.key].name
      }
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = merge(
      { network = var.network_name },
      var.instance.ipv4_address == null ? {} : { "ipv4.address" = var.instance.ipv4_address }
    )
  }

  lifecycle {
    ignore_changes = [image]
  }
}