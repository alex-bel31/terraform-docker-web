variable "name" {
  description = "Name of MySQL cluster"
  type        = string
  default     = "mysql-cluster"
}

variable "environment" {
  description = "Environment type: PRODUCTION or PRESTABLE"
  type        = string
  default     = "PRESTABLE"
  validation {
    condition     = contains(["PRODUCTION", "PRESTABLE"], var.environment)
    error_message = "Release channel should be PRODUCTION (stable feature set) or PRESTABLE (early bird feature access)."
  }
}

variable "network_id" {
  description = "MySQL cluster network id"
  type        = string
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0"
  validation {
    condition     = contains(["5.7", "8.0"], var.mysql_version)
    error_message = "Allowed MySQL versions are 5.7, 8.0."
  }
}

variable "security_groups_ids_list" {
  description = "A list of security group IDs to which the MySQL cluster belongs"
  type        = list(string)
  default     = []
}

variable "disk_size" {
  description = "Disk size for hosts"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Disk type for hosts"
  type        = string
  default     = "network-hdd"
}

variable "resource_preset_id" {
  description = "Preset for hosts"
  type        = string
  default     = "b1.medium"
}

variable "ha" {
  description = "High Availability: True - 2 hosts; False - 1 host"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Location area and subnetwork ID"
  type = list(object({
    zone      = string
    subnet_id = string
  }))
}

variable "databases" {
  description = "List of MySQL databases"
  type = list(object({
    name = string
  }))
  default = []
}

variable "users" {
  description = "MySQL user list"
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}
