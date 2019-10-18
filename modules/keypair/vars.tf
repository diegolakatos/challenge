variable "client_name" {
  default = "undefined"
}

variable "environment" {
  default = "dev"
}

variable "ssh_public_key_path" {
  description = "Path to Read/Write SSH Public Key File (directory)"
  default     = "."
}

variable "generate_ssh_key" {
  default = "true"
}

variable "ssh_key_algorithm" {
  default = "RSA"
}

variable "private_key_extension" {
  type    = "string"
  default = ""
}

variable "public_key_extension" {
  type    = "string"
  default = ".pub"
}
