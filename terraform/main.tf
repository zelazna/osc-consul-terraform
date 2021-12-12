terraform {
  required_providers {
    outscale = {
      source  = "outscale-dev/outscale"
      version = "0.3.1"
    }
  }
}

provider "outscale" {
  access_key_id = var.access_key_id
  secret_key_id = var.secret_key_id
  region        = var.region
}

#FIXME
locals {
  data = {
    retry_join   = trim(chomp(join(" ", formatlist("%s=%s ", keys(var.retry_join), values(var.retry_join)))), " ")
    server_count = var.server_count
    region       = var.region
  }
}

resource "outscale_keypair" "bastion" {
  keypair_name = "bastion-keypair"
  public_key   = file("~/.ssh/id_rsa.pub")
}

resource "outscale_vm" "server" {
  image_id                 = var.ami
  vm_type                  = var.vm_type
  keypair_name             = outscale_keypair.bastion.keypair_name
  security_group_ids       = [outscale_security_group.primary.security_group_id]
  placement_subregion_name = "${var.region}a"
  count                    = var.server_count
  subnet_id                = outscale_subnet.nomad_subnet.subnet_id
  user_data                = data.cloudinit_config.server.rendered

  tags {
    key   = "name"
    value = "server-${count.index}"
  }
}

resource "outscale_vm" "client" {
  image_id                 = var.ami
  vm_type                  = var.vm_type
  keypair_name             = outscale_keypair.bastion.keypair_name
  security_group_ids       = [outscale_security_group.primary.security_group_id]
  placement_subregion_name = "${var.region}a"
  count                    = var.client_count
  subnet_id                = outscale_subnet.nomad_subnet.subnet_id
  user_data                = data.cloudinit_config.client.rendered

  tags {
    key   = "name"
    value = "client-${count.index}"
  }
}

resource "outscale_vm" "bastion" {
  image_id                 = var.ami
  vm_type                  = var.vm_type
  keypair_name             = outscale_keypair.bastion.keypair_name
  security_group_ids       = [outscale_security_group.bastion.security_group_id]
  placement_subregion_name = "${var.region}a"
  subnet_id                = outscale_subnet.nomad_subnet.subnet_id

  tags {
    key   = "osc.fcu.eip.auto-attach"
    value = outscale_public_ip.bastion_ip.public_ip
  }

  tags {
    key   = "name"
    value = "bastion"
  }
}