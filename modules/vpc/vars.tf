variable cidr_block {
  default = "10.0.0.0/16"
}

variable vpc_name {
  default = "prod-vpc"
}

variable "cidr_network_bits" {
  default = "4"
}

variable "subnet_count" {
  default = "2"
}

variable "zone_name" {
  default = "us-east-1a"
}
