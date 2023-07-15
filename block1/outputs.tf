output "private_keys" {
  value = {
    for k, keys in module.keys : k => keys.private_key_pem
  }
  sensitive = true
}