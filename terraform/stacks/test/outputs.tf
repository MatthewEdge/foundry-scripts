output "instance_ip_addr" {
  value = aws_instance.foundry_instance.public_ip
}

output "instance_key_name" {
  value = aws_instance.foundry_instance.key_name
}
