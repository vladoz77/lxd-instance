# terraform-lxd-instance

Terraform-модуль для создания **виртуальной машины LXD** с cloud-init, дополнительными block-томами и статическим IP (или DHCP).

Только `virtual-machine`, контейнеры не поддерживаются.

## Возможности

- VM с заданными CPU, памятью и размером root-диска
- дополнительные block-тома (`lxd_storage_volume`), подключаемые как диски
- статический IPv4 на NIC или DHCP (`ipv4_address = null`)
- доставка cloud-init через устройство `cloud-init:config` (нужно для кастомных образов без `lxd-agent`)
- смена тега образа не пересоздаёт VM (`ignore_changes = [image]`)

## Требования

| Что | Версия |
|---|---|
| Terraform | `>= 1.3` (используется `optional()` с дефолтами) |
| Провайдер `terraform-lxd/lxd` | `~> 3.0` |

Образ должен быть **VM-вариантом** и содержать cloud-init. Если в образе нет `lxd-agent`, `lxc exec` работать не будет, а выход `ipv4_address` может быть `null` (см. «Ограничения»).

## Использование

```hcl
module "instance" {
  source = "git::https://github.com/vladoz77/terraform-lxd-instance.git?ref=v1.0.0"

  network_name = "lxdbr0"
  profiles     = ["k8s-profile"]

  instance = {
    name           = "k8s-master-01"
    image          = "rocky9-cloud"
    cpu            = 2
    memory         = "4GiB"
    root_disk_pool = "root-k8s"
    root_disk_size = "20GiB"
    ipv4_address   = "172.10.10.11"
    cloud_init     = file("${path.module}/cloud-init.yaml")
  }

  volumes = {
    data = {
      size = "50GiB"
      pool = "data-k8s"
    }
  }
}
```

Несколько нод:

```hcl
module "instance" {
  for_each = var.instances
  source   = "git::https://github.com/vladoz77/terraform-lxd-instance.git?ref=v1.0.0"
  # ...
}
```

## Входные переменные

| Имя | Тип | По умолчанию | Описание |
|---|---|---|---|
| `network_name` | `string` | — | LXD-сеть, к которой подключается `eth0` |
| `profiles` | `list(string)` | `["default"]` | профили LXD |
| `instance` | `object` | — | параметры VM (ниже) |
| `volumes` | `map(object)` | `{}` | дополнительные block-тома, ключ = имя устройства |

### `instance`

| Поле | Тип | По умолчанию | Описание |
|---|---|---|---|
| `name` | `string` | — | имя VM |
| `image` | `string` | — | VM-образ с cloud-init |
| `cpu` | `number` | — | число vCPU (> 0) |
| `memory` | `string` | — | `4GiB` или `2048MiB` |
| `root_disk_pool` | `string` | — | пул хранилища для root-диска |
| `root_disk_size` | `string` | `"20GiB"` | размер root-диска |
| `ipv4_address` | `string` | `null` | статический IPv4; `null` — адрес выдаст DHCP |
| `cloud_init` | `string` | `null` | содержимое `cloud-init.user-data`; `null` — не задавать |

### `volumes`

| Поле | Тип | Описание |
|---|---|---|
| `size` | `string` | размер тома, например `50GiB` |
| `pool` | `string` | пул хранилища |

Имя тома в LXD: `<instance.name>-<ключ>`.

## Выходные значения

| Имя | Описание |
|---|---|
| `instance_name` | имя VM |
| `ipv4_address` | IPv4, который вернул провайдер (из состояния гостя) |
| `volumes` | созданные тома: `name`, `pool`, `size` |


