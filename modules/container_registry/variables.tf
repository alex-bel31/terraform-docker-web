variable "name" {
  description = "Name of security group"
  type        = string
  default     = "default"
}

variable "folder_id" {
  description = "Folder ID for container registry"
  type        = string
}