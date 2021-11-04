#!/bin/bash -e

####################
# Installs Consul  #
# Ubuntu 20.04 LTS #
####################

# Nice to have local utilities
sudo apt-get install unzip curl vim -y

###
# Add HashiCorp Repos
###

# Throwing stdout of 'apt-key add' to /dev/null prevents scary red output.
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - &>/dev/null
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y

###
# Consul
###
sudo apt-get install -y consul

# Validate Install
consul --version &> /dev/null
if [[ $? == 0 ]]; then
    echo "Consul was installed successfully."
else
    echo "ERROR: Consul installation failed, Error Code: $?"
	exit 1
fi

sudo tee /etc/systemd/system/consul.service <<EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

###
# Enable for next boot
###

sudo systemctl enable consul
