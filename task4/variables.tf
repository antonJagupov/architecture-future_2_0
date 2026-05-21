variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
}

variable "zone" {
  description = "Availability zone"
}

variable "public_key_path" {
  description = "Path to public SSH key"
}

variable "image_family" {
  description = "VM image family (Ubuntu 22.04)"
  default     = "ubuntu-2204-lts"
}