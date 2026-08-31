output "public_subnet_id" {
  value = oci_core_subnet.public_subnet.id
}

# output "reserved_ip_address" {
#   value = oci_core_public_ip.reserved_ip.ip_address
# }

output "network_security_group_id" {
  value = oci_core_network_security_group.nlb_nsg.id
}