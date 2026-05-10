resource "oci_core_network_security_group" "nlb_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-nlb-nsg"
}

resource "oci_core_network_security_group_security_rule" "https3_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id
  direction                 = "INGRESS"
  description               = "http/3 port"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  protocol                  = "17" # UDP
  udp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "https_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "http_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}