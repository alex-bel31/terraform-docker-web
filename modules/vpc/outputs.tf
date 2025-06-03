output "subnet_info" {
  description = "Information about the created subnetwork"
  value = [
    for subnet in yandex_vpc_subnet.subnet : {
      id          = subnet.id
      zone        = subnet.zone
      cidr_blocks = subnet.v4_cidr_blocks
      network_id  = subnet.network_id
    }
  ]
}