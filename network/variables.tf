variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  type        = string
  description = "The region to provision the resources in"
}

variable "cloudflare_token" {
  type        = string
  description = "Cloudflare API token"
}