terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.75"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.zone
}

# Сеть VPC
# ... (первые строки terraform, provider, network, subnet - без изменений) ...

# Удаляем ресурс yandex_vpc_gateway и yandex_vpc_route_table
# NAT будем включать прямо на каждой ВМ через параметр nat = true

resource "yandex_vpc_network" "future2" {
  name = "future2-network"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "subnet-a"
  zone           = var.zone
  network_id     = yandex_vpc_network.future2.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

# Security Groups (оставляем)
resource "yandex_vpc_security_group" "common_sg" {
  name        = "common-sg"
  description = "Allow SSH, internal traffic"
  network_id  = yandex_vpc_network.future2.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Internal communication"
    v4_cidr_blocks = ["10.10.0.0/16"]
    from_port      = 1
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Образ Ubuntu
data "yandex_compute_image" "ubuntu_image" {
  family = var.image_family
}

# ======== ВМ Клиники (без отдельного диска) ========
resource "yandex_compute_instance" "clinic" {
  name        = "clinic-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2          # уменьшили ядра
    memory = 4          # уменьшили RAM
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 30     # GB (было 50)
      type     = "network-hdd"  # HDD вместо SSD (экономия квоты)
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    security_group_ids = [yandex_vpc_security_group.common_sg.id]
    nat                = true   # включаем NAT на интерфейсе
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

# ======== ВМ Финтех ========
resource "yandex_compute_instance" "fintech" {
  name        = "fintech-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    security_group_ids = [yandex_vpc_security_group.common_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

# ======== ВМ ИИ (больше ресурсов, но без отдельного диска) ========
resource "yandex_compute_instance" "ai" {
  name        = "ai-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 4          # было 8
    memory = 8          # было 32
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 50     # можно оставить побольше
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    security_group_ids = [yandex_vpc_security_group.common_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

# ======== ВМ Аналитика (большой диск, HDD) ========
resource "yandex_compute_instance" "analytics" {
  name        = "analytics-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 4          # было 16
    memory = 8          # было 64
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 100    # GB (вместо 500)
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    security_group_ids = [yandex_vpc_security_group.common_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

# ======== Kafka ВМ ========
resource "yandex_compute_instance" "kafka" {
  name        = "kafka-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 50
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    security_group_ids = [yandex_vpc_security_group.common_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}