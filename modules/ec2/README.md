# Modulo terraform para construção de ec2


## Variaveis

    variable "app_name" {}
    variable "subnet_id" {}
    variable "vpc_id" {}
    variable "key_pair" {}
    variable "availability_zone" {}

    variable "instance_type" {
      default = "t2.small"
    }

    variable "environment" {
      default = "dev"
    }

    variable "public_ip" {
      default = false
    }

    variable "aws_amis" {
      type = "map"

      default = {
        "us-east-1" = "ami-4fffc834"
      }
    }

    variable "ami_id" {
      default = "${lookup(var.aws_amis, var.region)}"
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

    variable "name_layout" {
      default = "aws-${var.environment}-${var.app_name}"
    }

