terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}


# convenience variables
locals {
  terraform_dir = "/home/gz/repos/Tesi/terraform-main"
}

provider "docker" {}

resource "docker_network" "siem_network" {
  name   = "siemnet"
  driver = "bridge"
  ipam_config {
    subnet  = "192.168.80.0/20"
    gateway = "192.168.80.1"
  }
}

resource "docker_network" "external_network" {
  name   = "extnet"
  driver = "bridge"
}

resource "docker_network" "shared_network" {
  name   = "sharednet"
  driver = "bridge"
  ipam_config {
    subnet = "172.30.0.0/16"
    gateway = "172.30.0.1"
  }
}

resource "docker_image" "web_server" {
  name         = "gianzav/simple-web-server"
  keep_locally = true
}

resource "docker_image" "elasticsearch" {
  name         = "docker.elastic.co/elasticsearch/elasticsearch:7.4.0"
  keep_locally = true
}

resource "docker_image" "logstash" {
  name         = "gianzav/logstash:7.4.0"
  keep_locally = true
}

resource "docker_image" "kibana" {
  name         = "docker.elastic.co/kibana/kibana:7.4.0"
  keep_locally = true
}

resource "docker_image" "dsiem-filebeat-suricata" {
  name         = "gianzav/dfs:7.4.0"
  keep_locally = true
  #  build {
  #    path = "../docker_images/dsiem_filebeat_suricata/"
  #    tag = ["dfs:latest"]
  #  }
}

resource "docker_image" "filebeat-es" {
  name         = "gianzav/filebeat-es:7.4.0"
  keep_locally = true
}

resource "docker_image" "ubuntu" {
  name         = "gianzav/ubuntu-utils"
  keep_locally = true
}


resource "docker_container" "web-server" {
  image = docker_image.web_server.latest
  name  = "web-server"
  ports {
    internal = 80
    external = 12345
  }
  networks_advanced {
    name = "siemnet"
    ipv4_address = "192.168.80.10"
  }
  hostname = "web-server"
  capabilities {
    add = ["NET_ADMIN"]
  }
}

resource "docker_container" "client" {
  image = docker_image.ubuntu.latest
  name  = "client"
  networks_advanced {
    name = "extnet"
  }

  networks_advanced {
    name = "sharednet"
    ipv4_address = "172.30.0.3"
  }
  hostname = "client"
  init     = true
  command  = ["sleep", "1h"]
  capabilities {
    add = ["NET_ADMIN"]
  }
}

resource "docker_container" "elasticsearch" {
  image = docker_image.elasticsearch.latest
  name  = "elasticsearch"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.3"
  }
  hostname = "elasticsearch"
  ports {
    internal = 9200
    external = 9200
  }
  #  env = ["discovery.type=single-node",
  #    "ES_JAVA_OPTS=-Xms256m -Xmx256m",
  #    "cluster.routing.allocation.disk.threshold_enabled=false",
  #    "xpack.security.enabled=false",
  #    "xpack.monitoring.enabled=false",
  #    "xpack.ml.enabled=false",
  #    "xpack.graph.enabled=false",
  #    "xpack.watcher.enabled=false",
  #    "http.cors.enabled=true",
  #  "http.cors.allow-origin='/https?://localhost(:[0-9]+)?/'"]

  env = ["discovery.type=single-node",
    "ES_JAVA_OPTS=-Xms256m -Xmx256m",
    "cluster.routing.allocation.disk.threshold_enabled=false",
    "xpack.security.enabled=false",
    "xpack.monitoring.enabled=false",
    "xpack.ml.enabled=false",
    "xpack.graph.enabled=false",
    "xpack.watcher.enabled=false",
    "http.cors.enabled=true",
    "http.cors.allow-origin=*",
    "http.cors.allow-headers: Authorization,X-Requested-With,Content-Type,Content-Length"
  ]
  volumes {
    container_path = "/usr/share/elasticsearch/data"
    volume_name    = "es-data"
  }
}



resource "docker_container" "logstash" {
  image = docker_image.logstash.latest
  name  = "logstash"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.4"
  }
  hostname = "logstash"
  ports {
    internal = 5400
    external = 5400
  }
  env = ["XPACK_MONITORING_ENABLED=false"]
  volumes {
    container_path = "/usr/share/logstash/pipeline/70_siem-plugin-suricata.conf"
    host_path      = format("%s/%s", local.terraform_dir, "pipeline/70_siem-plugin-suricata.conf")
  }
  restart = "unless-stopped" 
}


resource "docker_container" "kibana" {
  image = docker_image.kibana.latest
  name  = "kibana"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.5"
  }
  hostname = "kibana"
  ports {
    internal = 5601
    external = 5601
  }
  env = ["XPACK_MONITORING_ENABLED=false"]
}


resource "docker_container" "dsiem-filebeat-suricata" {
  image = docker_image.dsiem-filebeat-suricata.latest
  name  = "dsiem"

  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.6"
  }
  networks_advanced {
    name = "sharednet"
    ipv4_address = "172.30.0.2"
  }
  hostname = "dsiem"
  ports {
    internal = 8080
    external = 8080
  }

  capabilities {
    add = ["NET_ADMIN", "SYS_ADMIN"]
  }
  privileged = true

  env = ["DSIEM_WEB_ESURL=http://elasticsearch:9200",
  "DSIEM_WEB_KBNURL=http://kibana:5601"]

  volumes {
    container_path = "/dsiem/logs"
    volume_name    = "dsiem-log"
  }
  volumes {
    volume_name    = "suricata-log"
    container_path = "/var/log/suricata"
  }
  volumes {
    container_path = "/usr/share/filebeat/data"
    volume_name    = "filebeat-data"
  }
  volumes {
    container_path = "/var/dsiem/configs"
    host_path      = format("%s/%s", local.terraform_dir, "dsiem_directives")
  }
  volumes {
    container_path = "/dsiem/configs"
    host_path      = format("%s/%s", local.terraform_dir, "dsiem_directives")
  }
  volumes {
    container_path = "/var/lib/suricata/rules/"
    host_path      = format("%s/%s", local.terraform_dir, "suricata_rules/")
  }
  volumes {
    container_path = "/var/dsiem/web/dist/assets/config/esconfig.json"
    host_path      = format("%s/%s", local.terraform_dir, "esconfig.json")
  }
  volumes {
    container_path = "/var/dsiem/dpluger_suricata.json"
    host_path      = format("%s/%s", local.terraform_dir, "dpluger_suricata.json")
  }
}


resource "docker_container" "filebeat-es" {
  image = docker_image.filebeat-es.latest
  name  = "filebeat-es"
  user  = "root"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.7"
  }
  hostname = "filebeat-es"
  volumes {
    container_path = "/usr/share/filebeat/data"
    volume_name    = "filebeat-es-data"
  }
  volumes {
    container_path = "/var/log/dsiem"
    volume_name    = "dsiem-log"
  }
}



resource "docker_volume" "dsiem-log" {
  name = "dsiem-log"
}

resource "docker_volume" "filebeat-data" {
  name = "filebeat-data"
}

resource "docker_volume" "filebeat-es-data" {
  name = "filebeat-es-data"
}

resource "docker_volume" "suricata-log" {
  name = "suricata-log"
}

resource "docker_volume" "es-data" {
  name = "es-data"
}
