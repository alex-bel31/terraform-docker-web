module "container_registry" {
  source    = "./modules/container_registry"
  name      = "docker-registry"
  folder_id = var.folder_id
}

resource "null_resource" "build_push_image" {

  depends_on = [module.container_registry]

  provisioner "local-exec" {
    command = <<EOT
        IMAGE="cr.yandex/${module.container_registry.registry_id}/webapp:latest"
        DOCKERFILE_DIR="${path.module}/app"
        docker build -t "$IMAGE" "$DOCKERFILE_DIR"
        docker push "$IMAGE"
      EOT
  }
}

