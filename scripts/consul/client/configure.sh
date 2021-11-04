#!/bin/bash -e

CONSUL_SERVER_ADDR="${1}"

###
# Configure Consul Client
###
sudo tee /etc/consul.d/consul.hcl <<EOF
datacenter = "dc1"
data_dir = "/opt/consul"

# https://www.consul.io/docs/agent/options#bind_addr
bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"172.28.0.0/16\" | attr \"address\" }}"

# https://www.nomadproject.io/docs/integrations/consul-connect#consul
ports = {
  grpc = 8502
}

connect = {
  enabled = true
}

# https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure#configure-the-clients
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
ca_file = "/opt/certs/consul-agent-ca.pem"
auto_encrypt = {
  tls = true
}

# https://learn.hashicorp.com/tutorials/consul/deployment-guide#enable-consul-acls
acl = {
  enabled = true
  default_policy = "allow"
  enable_token_persistence = true
}

# https://learn.hashicorp.com/tutorials/consul/deployment-guide#performance-stanza
performance {
  raft_multiplier = 1
}

# Consul Server to join
retry_join = ["${CONSUL_SERVER_ADDR}"]
EOF

sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl
