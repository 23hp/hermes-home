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

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "latest_image" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  filter {
    name   = "display_name"
    values = ["^.*-aarch64-.*$"]
    regex  = true
  }
}

locals {
  subnet = data.oci_core_subnets.found_subnet.subnets[0]
  azs = data.oci_identity_availability_domains.ads.availability_domains[*].name
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.35.2"
  name               = "k8s-cluster"
  vcn_id             = local.subnet.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = local.subnet.id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [local.subnet.id]
  }
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.35.2"
  name               = "k8s-node-pool"
  node_config_details {
    dynamic placement_configs {
      for_each = local.azs
      content {
        availability_domain = placement_configs.value
        subnet_id           = local.subnet.id
      }
    }
    size = 1

  }
  node_shape = "VM.Standard.A1.Flex"

  node_shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  node_source_details {
    image_id    = data.oci_core_images.latest_image.images.0.id
    source_type = "image"
  }

  initial_node_labels {
    key   = "name"
    value = "k8s-cluster"
  }

  ssh_public_key = var.ssh_public_key
}

# export kube config
resource "null_resource" "export_kube_config" {

  provisioner "local-exec" {
    command = "oci ce cluster create-kubeconfig --cluster-id $cluster_id --file $kube_config --region $oci_region --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"

    environment = {
      cluster_id  = oci_containerengine_cluster.k8s_cluster.id
      oci_region  = var.region
      kube_config = var.kube_config_path
    }
  }
}