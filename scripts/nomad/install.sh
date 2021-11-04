#!/bin/bash -e

################################
# Installs Nomad & Consul      #
# Built using Ubuntu 20.04 LTS #
################################

###
# Install Docker
###
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker.io

# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant
echo "Successfully Installed: $(sudo docker --version)"

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
# Nomad & Consul
###
sudo apt-get install -y nomad consul

# Validate Install
nomad version &> /dev/null
if [[ $? == 0 ]]; then
    echo "Nomad was installed successfully."
else
    echo "ERROR: Nomad installation failed, Error Code: $?"
	exit 1
fi

# https://learn.hashicorp.com/tutorials/nomad/production-deployment-guide-vm-with-consul#configure-systemd
sudo tee /etc/systemd/system/nomad.service << EOF
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
#Wants=consul.service
#After=consul.service

[Service]
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2

## Configure unit start rate limiting. Units which are started more than
## *burst* times within an *interval* time span are not permitted to start any
## more. Use 'StartLimitIntervalSec' or 'StartLimitInterval' (depending on
## systemd version) to configure the checking interval and 'StartLimitBurst'
## to configure how many starts per interval are allowed. The values in the
## commented lines are defaults.

# StartLimitBurst = 5

## StartLimitIntervalSec is used for systemd versions >= 230
# StartLimitIntervalSec = 10s

## StartLimitInterval is used for systemd versions < 230
# StartLimitInterval = 10s

TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
EOF

###
# Consul
###

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

sudo systemctl enable nomad consul
