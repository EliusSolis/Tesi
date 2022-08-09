terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "net_test" {
  name = "network_test"
  ipam_config {
    gateway = "172.19.0.1"
    subnet  = "172.19.0.0/16"
  }

}

resource "docker_image" "server" {
  name = "nginx:latest"
}

resource "docker_image" "client" {
  name = "ubuntu:focal"
}

resource "docker_container" "server" {
  image = docker_image.server.latest
  name  = "server"
  networks_advanced {
    name         = "network_test"
    ipv4_address = "172.19.0.20"
  }
  hostname = "server"
  ports {
    internal = 80
    external = 7634
  }
}

resource "docker_container" "client" {
  image   = docker_image.client.latest
  name    = "client"
  command = ["sleep", "600"]
  networks_advanced {
    name         = "network_test"
    ipv4_address = "172.19.0.22"
  }
}
