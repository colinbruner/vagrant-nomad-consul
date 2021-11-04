#!/bin/bash

sudo tee /etc/nomad.d/nomad.hcl << EOF
datacenter = "dc1"
data_dir = "/opt/nomad/data"
bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
}
EOF
