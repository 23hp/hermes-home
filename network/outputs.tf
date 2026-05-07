output "public_subnet_id" {
  value = oci_core_subnet.public_subnet.id
}

output "reserved_ip_id" {
  value = oci_core_public_ip.reserved_ip.id
}

output "reserved_ip_address" {
  value = oci_core_public_ip.reserved_ip.ip_address
}