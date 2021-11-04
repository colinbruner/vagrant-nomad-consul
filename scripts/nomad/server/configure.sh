#!/bin/bash

sudo tee /etc/nomad.d/server.hcl << EOF
data_dir = "/opt/nomad/data"

server {
  enabled          = true
  bootstrap_expect = 1
}
EOF
