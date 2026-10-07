# variables.tf
variable "network_name" {
  description = "LXD network (bridge/OVN), к которой подключается eth0"
  type        = string
}

variable "profiles" {
  description = "LXD profiles, применяемые к инстансу"
  type        = list(string)
  default     = ["default"]
}

variable "instance" {
  description = <<-EOT
    Параметры VM.
    image: VM-образ с cloud-init (например, ubuntu:24.04 / образы с /cloud).
    ipv4_address: null -> адрес выдаст DHCP.
    cloud_init: содержимое cloud-init.user-data, null -> не задавать.
  EOT
  type = object({
    name           = string
    image          = string
    cpu            = number
    memory         = string
    root_disk_pool = string
    root_disk_size = optional(string, "20GiB")
    ipv4_address   = optional(string)
    cloud_init     = optional(string)
  })

  validation {
    condition     = var.instance.cpu > 0
    error_message = "cpu должен быть больше 0."
  }
  validation {
    condition     = can(regex("^[0-9]+(MiB|GiB)$", var.instance.memory))
    error_message = "memory в формате 4GiB или 2048MiB."
  }
  validation {
    condition     = can(regex("^[0-9]+(MiB|GiB|TiB)$", var.instance.root_disk_size))
    error_message = "root_disk_size в формате 20GiB."
  }
  validation {
    condition     = var.instance.ipv4_address == null ? true : can(cidrhost("${var.instance.ipv4_address}/32", 0))
    error_message = "ipv4_address должен быть валидным IPv4-адресом или null."
  }
}

variable "volumes" {
  description = "Дополнительные block-тома: ключ = имя устройства"
  type = map(object({
    size = string
    pool = string
  }))
  default = {}
}