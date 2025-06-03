variable "env_name" {
  description = "Network name"
  type        = string
}

variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "Location area and CIDR block for subnetwork"
}