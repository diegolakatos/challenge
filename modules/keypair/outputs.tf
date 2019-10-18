output "private_key_pem" {
  value = "${join(",", tls_private_key.default.*.private_key_pem)}"
}

output "public_key_openssh" {
  value = "${join(",", tls_private_key.default.*.public_key_openssh)}"
}

output "key_name" {
  value = "${join(",", aws_key_pair.generated.*.key_name)}"
}
