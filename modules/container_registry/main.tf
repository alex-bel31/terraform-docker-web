resource "yandex_container_registry" "default" {
  name      = var.name
  folder_id = var.folder_id
}