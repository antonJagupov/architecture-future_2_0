output "clinic_vm_ip" {
  value = yandex_compute_instance.clinic.network_interface[0].nat_ip_address
}

output "fintech_vm_ip" {
  value = yandex_compute_instance.fintech.network_interface[0].nat_ip_address
}

output "ai_vm_ip" {
  value = yandex_compute_instance.ai.network_interface[0].nat_ip_address
}

output "analytics_vm_ip" {
  value = yandex_compute_instance.analytics.network_interface[0].nat_ip_address
}

output "kafka_vm_ip" {
  value = yandex_compute_instance.kafka.network_interface[0].nat_ip_address
}

output "vpc_network_id" {
  value = yandex_vpc_network.future2.id
}