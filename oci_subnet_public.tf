resource "oci_core_public_ip" "reserved_ip" {
  display_name   = "load-balancer-reserved-ip"
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
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
  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "public-subnet-sl"

  egress_security_rules {
    description      = "Allow IPv4 traffic out"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  egress_security_rules {
    description      = "Allow IPv6 traffic out"
    destination      = "::/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  egress_security_rules {
    description      = "private subnet access"
    destination      = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    description = "Allow private subnet traffic in"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
  ingress_security_rules {
    description = "SSH"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    description = "Allow kubectl traffic in"
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
    description = "https3 port"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "17" # UDP
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