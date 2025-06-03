variable "cloud_id" {
  description = "Cloud ID"
  type        = string
  sensitive   = true
}

variable "folder_id" {
  description = "Folder ID"
  type        = string
  sensitive   = true
}

variable "default_zone" {
  description = "Default zone"
  type        = string
  sensitive   = true
}

variable "ssh_username" {
  description = "SSH username"
  type        = string
  sensitive   = true
}

variable "git_repo_url" {
  description = "URL git repository"
  type        = string
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

variable "security_group_ingress_app" {
  description = "Ingress rules for app security group"
  type = list(object({
    protocol          = string
    port              = number
    description       = optional(string)
    v4_cidr_blocks    = optional(list(string))
    security_group_id = optional(string)
  }))
  default = []
}

variable "security_group_egress_app" {
  description = "Egress rules for app security group"
  type = list(object({
    protocol       = string
    port           = optional(number)
    description    = optional(string)
    v4_cidr_blocks = optional(list(string))
  }))
  default = []
}

variable "security_group_ingress_db" {
  description = "Ingress rules for DB security group"
  type = list(object({
    protocol          = string
    port              = number
    description       = optional(string)
    v4_cidr_blocks    = optional(list(string))
    security_group_id = optional(string)
  }))
  default = []
}

variable "security_group_egress_db" {
  description = "Egress rules for DB security group"
  type = list(object({
    protocol       = string
    port           = optional(number)
    description    = optional(string)
    v4_cidr_blocks = optional(list(string))
  }))
  default = []
}