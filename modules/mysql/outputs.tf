output "cluster_name" {
  description = "MySQL cluster name"
  value       = yandex_mdb_mysql_cluster.mdb_mysql_cluster.name
}

output "databases" {
  description = "A list of databases names."
  value       = [for db in var.databases : db.name]
}

output "mysql_host_fqdn" {
  value = yandex_mdb_mysql_cluster.mdb_mysql_cluster.host[0].fqdn
}