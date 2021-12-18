resource "outscale_load_balancer" "server_lb" {
  load_balancer_name = "${var.name}-server-lb"
  subnets            = [outscale_subnet.public_subnet.subnet_id]

  listeners {
    backend_port           = 4646
    backend_protocol       = "HTTP"
    load_balancer_port     = 4646
    load_balancer_protocol = "HTTP"
  }
  listeners {
    backend_port           = 8500
    backend_protocol       = "HTTP"
    load_balancer_port     = 8500
    load_balancer_protocol = "HTTP"
  }
  security_groups = [outscale_security_group.server_lb.security_group_id]
}

resource "outscale_load_balancer_vms" "backend_vms" {
  load_balancer_name = outscale_load_balancer.server_lb.load_balancer_name
  backend_vm_ids     = concat(outscale_vm.server.*.vm_id, outscale_vm.client.*.vm_id)
}