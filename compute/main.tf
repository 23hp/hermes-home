terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.31.0"
    }
  }
}

provider "oci" {
  region = var.region
}

data "oci_core_subnets" "found_subnet" {
  compartment_id = var.compartment_id
  display_name   = "fixed-public-subnet"
}

data "oci_core_public_ips" "found_ip" {
  compartment_id = var.compartment_id
  scope          = "REGION"
  filter {
    name   = "display_name"
    values = ["my_fixed_ip_resource"]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "latest_image" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  filter {
    name   = "display_name"
    values = ["^.*-aarch64-.*$"]
    regex  = true
  }
}

resource "oci_core_instance" "instance" {
  compartment_id      = var.compartment_id
  display_name        = "nix"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.latest_image.images.0.id
    boot_volume_size_in_gbs = 200
  }

  create_vnic_details {
    subnet_id        = data.oci_core_subnets.found_subnet.subnets[0].id
    assign_public_ip = true
    assign_ipv6ip    = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}