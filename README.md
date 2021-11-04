# Nomad Local w/ Consul Connect (feat: Vagrant)

## Setup
The following will create two VMs: 1 Nomad Server & 1 Nomad Consul. 

### Creating Consul Certs
If no certs exist locally in the [certs](./certs/) directory, run the following to generate them.
```bash
# Create CA
consul tls ca create
# Create servers being created
consul tls cert create -server
```

### Creating VMs
Running start.sh will start the necessary services. This will forward local ports 8000-8099 to the Nomad server.
```bash
$ vagrant up
$ ./start.sh
```

## Validating
Once your cluster is created, run any of the following jobspecs to validate things are working.

### Basic
Simple container that returns arbitrary text on a port.
```bash
$ export NOMAD_ADDR=http://localhost:4646
$ nomad run jobspecs/basic.nomad
$ curl localhost:8080
hello world
```

### Sidecar
This creates a Envoy sidecar proxy with Consul + Nomad.
```bash
$ export NOMAD_ADDR=http://localhost:4646
$ nomad run jobspecs/sidecar.nomad
$ open localhost:8000
```

### Ingress
Creates an ingress service to register to Consul, maps traffic through that to UUID generator app.
```bash
$ export NOMAD_ADDR=http://localhost:4646
$ nomad run jobspecs/sidecar.nomad
$ curl -H 'Host: uuid-api.ingress.dc1.consul:8080' http://localhost:8080
b3e90018-05f3-30a7-2423-79a855d4eafd
```
