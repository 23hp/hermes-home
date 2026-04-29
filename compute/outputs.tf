output "instance_id" {
  value = oci_core_instance.instance.id
}

output "reserved_ip_address" {
  value = oci_core_public_ip.ip_binding.ip_address
}