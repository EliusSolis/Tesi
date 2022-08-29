terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_container" "filebeat-es" {
  name = "filebeat-es"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.7"
  }

  user = "root"
  volumes {
    volume_name    = "filebeat-es-data"
    container_path = "/usr/share/filebeat/data"

  }
  volumes {
    volume_name    = "dsiem-log"
    container_path = "/var/log/dsiem"

  }
  hostname = "filebeat-es"
  image    = docker_image.image0.latest
}
resource "docker_container" "elasticsearch" {
  ports {
    internal = 9200
    external = 9200
    protocol = "tcp"
    ip       = "0.0.0.0"
  }

  volumes {
    volume_name    = "es-data"
    container_path = "/usr/share/elasticsearch/data"

  }
  env = [
    "http.cors.enabled=true",
    "xpack.watcher.enabled=false",
    "xpack.security.enabled=false",
    "xpack.monitoring.enabled=false",
    "xpack.ml.enabled=false",
    "http.cors.allow-origin=*",
    "ES_JAVA_OPTS=-Xms256m -Xmx256m",
    "cluster.routing.allocation.disk.threshold_enabled=false",
    "discovery.type=single-node",
    "xpack.graph.enabled=false",
    "http.cors.allow-headers=Authorization,X-Requested-With,Content-Type,Content-Length"
  ]
  hostname = "elasticsearch"
  image    = docker_image.image1.latest
  name     = "elasticsearch"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.3"
  }

}
resource "docker_volume" "filebeat-data" {
  name   = "filebeat-data"
  driver = "local"
}
resource "docker_volume" "es-data" {
  driver = "local"
  name   = "es-data"
}
resource "docker_container" "kibana" {
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.5"
  }

  ports {
    internal = 5601
    external = 5601
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  env = [
    "XPACK_MONITORING_ENABLED=false"
  ]
  hostname = "kibana"
  image    = docker_image.image2.latest
  name     = "kibana"
}
resource "docker_volume" "dsiem-log" {
  name   = "dsiem-log"
  driver = "local"
}
resource "docker_volume" "suricata-log" {
  driver = "local"
  name   = "suricata-log"
}
resource "docker_container" "logstash" {
  env = [
    "XPACK_MONITORING_ENABLED=false"
  ]
  hostname = "logstash"
  image    = docker_image.image3.latest
  name     = "logstash"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.4"
  }

  ports {
    external = 5400
    ip       = "0.0.0.0"
    protocol = "tcp"
    internal = 5400
  }

  volumes {
    container_path = "/usr/share/logstash/pipeline/70_siem-plugin-suricata.conf"
    host_path      = "/home/gz/repos/Tesi/terraform-main/pipeline/70_siem-plugin-suricata.conf"

  }
}
resource "docker_volume" "filebeat-es-data" {
  driver = "local"
  name   = "filebeat-es-data"
}
resource "docker_container" "client" {
  hostname = "client"
  image    = docker_image.image4.latest
  init     = true
  name     = "client"
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.2"
  }

  command = ["sleep", "1h"]
}
resource "docker_network" "siem_network" {
  driver     = "bridge"
  ip_version = 4
  name       = "siemnet"
  ipam_config {
    gateway = "192.168.80.1"
  }
  ipam_config {
    subnet = "192.168.80.0/20"
  }
}
resource "docker_container" "dsiem-filebeat-suricata" {
  hostname = "logstash"
  env = [
    "DSIEM_WEB_ESURL=http://elasticsearch:9200",
    "DSIEM_WEB_KBNURL=http://kibana:5601"
  ]
  image = docker_image.image5.latest
  networks_advanced {
    name         = "siemnet"
    ipv4_address = "192.168.80.6"
  }

  volumes {
    volume_name    = "dsiem-log"
    container_path = "/dsiem/logs"

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
    container_path = "/dsiem/configs/directives_dsiem.json"
    host_path      = "/home/gz/repos/Tesi/terraform-main/dsiem_directives"

  }
  volumes {
    container_path = "/var/lib/suricata/rules/"
    host_path      = "/home/gz/repos/Tesi/terraform-main/suricata_rules/"

  }
  volumes {
    host_path      = "/home/gz/repos/Tesi/terraform-main/esconfig.json"
    container_path = "/var/dsiem/web/dist/assets/config/esconfig.json"

  }
  volumes {
    container_path = "/var/dsiem/dpluger_suricata.json"
    host_path      = "/home/gz/repos/Tesi/terraform-main/dpluger_suricata.json"

  }
  name    = "dsiem"
  command = ["/bin/bash", "-c", "service suricata start && service filebeat start && /var/dsiem/dsiem serve --debug"]
  ports {
    protocol = "tcp"
    ip       = "0.0.0.0"
    internal = 8080
    external = 8080
  }

}
resource "docker_image" "image0" {
  name = "docker_image.filebeat-es.latest"
}
resource "docker_image" "image1" {
  name = "docker.elastic.co/elasticsearch/elasticsearch:7.4.0"
}
resource "docker_image" "image2" {
  name = "docker_image.kibana.latest"
}
resource "docker_image" "image3" {
  name = "docker_image.logstash.latest"
}
resource "docker_image" "image4" {
  name = "docker_image.ubuntu.latest"
}
resource "docker_image" "image5" {
  name = "docker_image.dsiem-filebeat-suricata.latest"
}
