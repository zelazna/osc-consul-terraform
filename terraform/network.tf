resource "outscale_net" "nomad_vpc" {
  ip_range = "10.0.0.0/16"
}

resource "outscale_subnet" "nomad_subnet" {
  net_id         = outscale_net.nomad_vpc.net_id
  ip_range       = "10.0.0.0/24"
  subregion_name = "${var.region}a"
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

resource "outscale_route_table" "route_table" {
  net_id = outscale_net.nomad_vpc.net_id
}

resource "outscale_route_table_link" "route_table_link" {
  subnet_id      = outscale_subnet.nomad_subnet.subnet_id
  route_table_id = outscale_route_table.route_table.id
}

resource "outscale_route" "route" {
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.internet_service.internet_service_id
  route_table_id       = outscale_route_table.route_table.route_table_id
}