data "cloudflare_zones" "zones" {}

locals {
  reserved_ip_addr = oci_core_public_ip.reserved_ip.ip_address
  zone_id          = data.cloudflare_zones.zones.result[0].id
}

resource "cloudflare_dns_record" "zone_apex" {
  zone_id = local.zone_id
  name    = "@"
  ttl     = 1
  type    = "A"
  comment = "zone apex record"
  content = local.reserved_ip_addr
  proxied = true
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = local.zone_id
  name    = "*"
  ttl     = 1
  type    = "A"
  comment = "wildcard records"
  content = local.reserved_ip_addr
  proxied = true
}