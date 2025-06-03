resource "yandex_mdb_mysql_cluster" "mdb_mysql_cluster" {
  name               = var.name
  environment        = var.environment
  network_id         = var.network_id
  version            = var.mysql_version
  security_group_ids = var.security_groups_ids_list

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type
    disk_size          = var.disk_size
  }

  dynamic "host" {
    for_each = var.ha ? [0, 1] : [0]
    content {
      name      = "${var.name}-host-${host.key}"
      zone      = var.subnets[host.key].zone
      subnet_id = var.subnets[host.key].subnet_id
    }
  }
}

resource "yandex_mdb_mysql_database" "database" {
  for_each   = length(var.databases) > 0 ? { for db in var.databases : db.name => db } : {}
  cluster_id = yandex_mdb_mysql_cluster.mdb_mysql_cluster.id
  name       = lookup(each.value, "name", null)
}

resource "yandex_mdb_mysql_user" "user" {
  for_each   = length(var.users) > 0 ? { for user in var.users : user.name => user } : {}
  cluster_id = yandex_mdb_mysql_cluster.mdb_mysql_cluster.id
  name       = each.value.name
  password   = each.value.password
  depends_on = [yandex_mdb_mysql_database.database]
}