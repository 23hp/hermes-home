variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  type        = string
  description = "The region to provision the resources in"
}

variable "ssh_public_key" {
  type        = string
  description = "Your SSH public key content (e.g., ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...)"
  sensitive   = false
}

variable "k8s_ver" {
  type        = string
  description = "kubernetes_version"
  default     = "v1.35.2"
}

variable "kube_config_path" {
  type = string
  default     = "~/.kube/config"
}