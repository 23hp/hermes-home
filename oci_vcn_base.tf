resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  is_ipv6enabled = true
  display_name   = "k8s-vcn"
  dns_label      = "k8svcn"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "Internet Gateway"
  enabled        = true
}

resource "oci_core_nat_gateway" "nat_gw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-nat-gateway"
}

data "oci_core_services" "all_services" {}

resource "oci_core_service_gateway" "svc_gw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-service-gateway"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}