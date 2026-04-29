variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  type        = string
  description = "The region to provision the resources in"
}

variable "instance_pool_size" {
  type        = number
  description = "Number of instances in the instance pool"
  default     = 4
}

variable "ssh_public_key" {
  type        = string
  description = "Your SSH public key content (e.g., ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...)"
  sensitive   = false
}
