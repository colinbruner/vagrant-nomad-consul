#!/bin/bash

vagrant ssh nomad -c 'sudo systemctl start consul nomad' &
vagrant ssh consul -c 'sudo systemctl start consul' &
