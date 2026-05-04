terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.12.0"
    }
  }
}

provider "oci" {
  region = var.region
}

resource "oci_core_vcn" "vcn" {
  compartment_id          = var.compartment_id
  cidr_block              = "10.0.0.0/16"
  is_ipv6enabled          = true
  display_name            = "k8s-vcn"
  dns_label               = "k8svcn"
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

resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-public-route-table"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "public-subnet-sl"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  egress_security_rules {
    description = "private subnet access"
    destination      = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    description = "HTTP"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "HTTPS"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    description  = "https3 port"
    stateless     = false
    source        = "0.0.0.0/0"
    source_type   = "CIDR_BLOCK"
    protocol      = "17" # UDP
    udp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_subnet" "public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-public-subnet"

  cidr_block        = "10.0.0.0/24"
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 1)
  route_table_id    = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_subnet_sl.id]
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-private-route-table"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gw.id
  }
  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.svc_gw.id
  }
}

resource "oci_core_security_list" "private_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-private-subnet-sl"
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}

resource "oci_core_subnet" "vcn_private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = "10.0.1.0/24"
  route_table_id = oci_core_route_table.private_route_table.id

  security_list_ids          = [oci_core_security_list.private_subnet_sl.id]
  display_name               = "k8s-private-subnet"
  prohibit_public_ip_on_vnic = true
}
