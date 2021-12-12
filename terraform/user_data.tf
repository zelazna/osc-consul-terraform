data "cloudinit_config" "server" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
                   #! /bin/bash
                   sudo bash /ops/scripts/server.sh "${local.data.server_count}" "${local.data.retry_join}"
EOF
  }
}

data "cloudinit_config" "client" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
                   #! /bin/bash
                   sudo bash /ops/scripts/client.sh "${local.data.retry_join}"
EOF
  }
}