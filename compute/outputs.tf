output "instance_id" {
  value = oci_core_instance.instance.id
}

output "instance_public_ip" {
  value       = oci_core_instance.instance.public_ip
  description = "Public IP address of the instance"
}