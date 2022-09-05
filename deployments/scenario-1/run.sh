#!/bin/sh
puccini-tosca compile --exec terraform.generate --output=terraform.tf input.yaml
sudo terraform init
sudo terraform validate
sudo terraform fmt
sudo terraform apply -auto-approve
