terraform {
  required_providers {
    outscale = {
      source  = "outscale-dev/outscale"
      version = "0.5.0"
    }
  }
}

provider "outscale" {
  access_key_id = var.access_key_id
  secret_key_id = var.secret_key_id
  region        = var.region
}

resource "outscale_keypair" "bastion" {
  keypair_name = "bastion-keypair"
  public_key   = file("~/.ssh/id_rsa.pub")
}

resource "outscale_vm" "server" {
  image_id                 = var.ami
  vm_type                  = var.vm_type
  keypair_name             = outscale_keypair.bastion.keypair_name
  placement_subregion_name = "${var.region}a"
  count                    = var.server_count
  user_data = base64encode(<<EOF
    sudo bash /ops/scripts/server.sh "${var.server_count}" "${var.retry_join}"
    EOF
  )

  tags {
    key   = "name"
    value = "server-${count.index}"
  }

  nics {
    nic_id        = outscale_nic.nic01.nic_id
    device_number = "0"
  }
}

resource "outscale_vm" "client" {
  image_id                 = var.ami
  vm_type                  = var.vm_type
  keypair_name             = outscale_keypair.bastion.keypair_name
  security_group_ids       = [outscale_security_group.primary.security_group_id]
  placement_subregion_name = "${var.region}a"
  count                    = var.client_count
  subnet_id                = outscale_subnet.private_subnet.subnet_id
  user_data = base64encode(<<EOF
    sudo bash /ops/scripts/client.sh "${var.retry_join}"
    EOF
  )

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
  subnet_id                = outscale_subnet.public_subnet.subnet_id

  tags {
    key   = "osc.fcu.eip.auto-attach"
    value = outscale_public_ip.bastion_ip.public_ip
  }

  tags {
    key   = "name"
    value = "bastion"
  }
}