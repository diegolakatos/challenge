variable "app_name" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "key_pair" {}

variable "instance_type" {
  default = "t2.small"
}

variable "environment" {
  default = "dev"
}

variable "user_data_file" {
  default = "user_data.tpl"
}

variable "allow_rdp" {
  default = false
}

variable "allow_ssh" {
  default = false
}

variable "allow_http" {
  default = false
}

variable "public_ip" {
  default = false
}

variable "attach_eip" {
  default = false
}

variable "ami_type" {
  default = "linux"
}

variable "aws_amis" {
  default = {
    "windows.ap-northeast-1" = "ami-28ddcf54"
    "windows.ap-northeast-2" = "ami-9cc16ff2"
    "windows.ap-south-1"     = "ami-6bb09404"
    "windows.ap-southeast-1" = "ami-b1a284cd"
    "windows.ap-southeast-2" = "ami-6179b003"
    "windows.ca-central-1"   = "ami-c633b5a2"
    "windows.eu-central-1"   = "ami-f0540c1b"
    "windows.eu-west-1"      = "ami-7b476202"
    "windows.eu-west-2"      = "ami-efd23288"
    "windows.eu-west-3"      = "ami-2aff4e57"
    "windows.sa-east-1"      = "ami-ae6534c2"
    "windows.us-east-1"      = "ami-438a523c"
    "windows.us-east-2"      = "ami-4683b323"
    "windows.us-west-1"      = "ami-73d2c113"
    "windows.us-west-2"      = "ami-fadcbc82"

    "linux.ap-northeast-1" = "ami-25bd2743"
    "linux.ap-northeast-2" = "ami-7248e81c"
    "linux.ap-south-1"     = "ami-5d99ce32"
    "linux.ap-southeast-1" = "ami-d2fa88ae"
    "linux.ap-southeast-2" = "ami-b6bb47d4"
    "linux.ca-central-1"   = "ami-dcad28b8"
    "linux.eu-central-1"   = "ami-337be65c"
    "linux.eu-west-1"      = "ami-6e28b517"
    "linux.eu-west-2"      = "ami-ee6a718a"
    "linux.eu-west-3"      = "ami-bfff49c2"
    "linux.sa-east-1"      = "ami-f9adef95"
    "linux.us-east-1"      = "ami-4bf3d731"
    "linux.us-east-2"      = "ami-e1496384"
    "linux.us-west-1"      = "ami-65e0e305"
    "linux.us-west-2"      = "ami-a042f4d8"
  }
}

variable "region" {
  default = "us-east-1"
}

variable "backup" {
  default = "yes"
}

variable "number_of_instances" {
  default = 1
}

variable "default_security_groups" {
  type = "list"
}
