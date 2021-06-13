output "server_lb_ip" {
  value = "http://${outscale_load_balancer.server_lb.dns_name}"
}

output "bastion_ip" {
  value = outscale_public_ip.bastion_ip.public_ip
}