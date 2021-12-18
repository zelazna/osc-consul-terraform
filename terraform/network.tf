resource "outscale_net" "nomad_vpc" {
  ip_range = "10.0.0.0/16"
}

## PUBLIC SUBNET
resource "outscale_subnet" "public_subnet" {
  net_id   = outscale_net.nomad_vpc.net_id
  ip_range = "10.0.1.0/24"

  tags {
    key   = "name"
    value = "public-subnet"
  }
}

resource "outscale_route_table" "route_table" {
  net_id = outscale_net.nomad_vpc.net_id

  tags {
    key   = "name"
    value = "rt-public-subnet"
  }
}

resource "outscale_route_table_link" "route_table_link" {
  subnet_id      = outscale_subnet.public_subnet.subnet_id
  route_table_id = outscale_route_table.route_table.id
}

resource "outscale_public_ip_link" "bastion_server" {
  vm_id     = outscale_vm.bastion.vm_id
  public_ip = outscale_public_ip.bastion_ip.public_ip
}

resource "outscale_internet_service" "internet_service" {
}

resource "outscale_internet_service_link" "internet_service_link" {
  net_id              = outscale_net.nomad_vpc.net_id
  internet_service_id = outscale_internet_service.internet_service.id
}

resource "outscale_route" "route" {
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.internet_service.internet_service_id
  route_table_id       = outscale_route_table.route_table.route_table_id
  depends_on           = [outscale_internet_service_link.internet_service_link]
}

## PRIVATE SUBNET
resource "outscale_subnet" "private_subnet" {
  net_id   = outscale_net.nomad_vpc.net_id
  ip_range = "10.0.2.0/24"

  tags {
    key   = "name"
    value = "private-subnet"
  }
}

resource "outscale_route_table" "route_table01" {
  net_id = outscale_net.nomad_vpc.net_id

  tags {
    key   = "name"
    value = "rt-private-subnet"
  }
}

resource "outscale_route_table_link" "outscale_route_table_link01" {
  subnet_id      = outscale_subnet.private_subnet.subnet_id
  route_table_id = outscale_route_table.route_table01.route_table_id
}

resource "outscale_route" "route01" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = outscale_nat_service.nat_service01.nat_service_id
  route_table_id       = outscale_route_table.route_table01.route_table_id
  depends_on           = [outscale_internet_service_link.internet_service_link]
}

resource "outscale_nat_service" "nat_service01" {
  subnet_id    = outscale_subnet.public_subnet.subnet_id
  public_ip_id = outscale_public_ip.nat_ip.public_ip_id
}

resource "outscale_nic" "nic01" {
  subnet_id          = outscale_subnet.private_subnet.subnet_id
  security_group_ids = [outscale_security_group.primary.security_group_id]

  private_ips {
    is_primary = true
    private_ip = var.retry_join
  }
}