terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.12.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "oci" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}