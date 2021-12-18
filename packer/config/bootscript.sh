#!/bin/bash
if [ ! -f /var/setup_vm ]; then
    curl 169.254.169.254/latest/user-data | bash
fi