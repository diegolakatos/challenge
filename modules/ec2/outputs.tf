output "instance_id" {
  value = "${join(",", aws_instance.ec2_generic_instance.*.id)}"
}

output "private_ip" {
  value = "${join(",", aws_instance.ec2_generic_instance.*.private_ip)}"
}

output "private_dns" {
  value = "${join(",", aws_instance.ec2_generic_instance.*.private_dns)}"
}

output "associate_public_ip_address" {
  value = "${join(",", aws_instance.ec2_generic_instance.*.associate_public_ip_address)}"
}

output "public_ip" {
  value = "${join(",", aws_instance.ec2_generic_instance.*.public_ip)}"
}

output "public_dns" {
  value = "${join(",", aws_instance.ec2_generic_instance.*.public_dns)}"
}

output "eip" {
  value = "${join(",", aws_eip.instance_eip.*.public_ip)}"
}
