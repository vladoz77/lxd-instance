variable "lxd_server_address" {
  type = string
}

variable "lxd_server_cert_fingerprint" {
  type = string
}

variable "image" {
  type    = string
  default = "ubuntu-26.04"
}

variable "lxd_client_cert_file" {
  type    = string
  default = "~/snap/lxd/common/config/client.crt"
}

variable "lxd_client_key_file" {
  type      = string
  default   = "~/snap/lxd/common/config/client.key"
  sensitive = true
}