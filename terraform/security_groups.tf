resource "outscale_security_group" "server_lb" {
  description = "server security group"
  net_id      = outscale_net.nomad_vpc.net_id
}

resource "outscale_security_group_rule" "server_lb_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.server_lb.id

  # Nomad
  rules {
    from_port_range = "4646"
    to_port_range   = "4646"
    ip_protocol     = "tcp"
    ip_ranges       = [var.whitelist_ip]
  }

  # Consul
  rules {
    from_port_range = "8500"
    to_port_range   = "8500"
    ip_protocol     = "tcp"
    ip_ranges       = [var.whitelist_ip]
  }
}


resource "outscale_security_group" "primary" {
  description = "primary security group"
  net_id      = outscale_net.nomad_vpc.net_id
}

resource "outscale_security_group_rule" "primary_lb_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.primary.id

  # Nomad
  rules {
    from_port_range = "4646"
    to_port_range   = "4646"
    ip_protocol     = "tcp"
    ip_ranges       = [var.whitelist_ip]
  }

  # Consul
  rules {
    from_port_range = "8500"
    to_port_range   = "8500"
    ip_protocol     = "tcp"
    ip_ranges       = [var.whitelist_ip]
  }
}

resource "outscale_security_group" "bastion" {
  description = "bastion security group"
  net_id      = outscale_net.nomad_vpc.net_id
}

data "http" "my_ip" {
  url = "https://api.ipify.org?format=text"
}

resource "outscale_security_group_rule" "bastion_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion.id

  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${chomp(data.http.my_ip.body)}/32"]
  }
}