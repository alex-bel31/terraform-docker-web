output "registry_id" {
  description = "ID of the container registry"
  value       = yandex_container_registry.default.id
}

output "registry_name" {
  description = "Name of the container registry"
  value       = yandex_container_registry.default.name
}