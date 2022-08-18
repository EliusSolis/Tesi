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
}


resource "docker_image" "elasticsearch" {
  name = "docker.elastic.co/elasticsearch/elasticsearch:7.4.0"
}

resource "docker_image" "logstash" {
  name = "defenxor/docker-logstash:7.4.0"
}

resource "docker_image" "kibana" {
  name = "docker.elastic.co/kibana/kibana:7.4.0"
}

resource "docker_image" "dsiem" {
  name = "defenxor/dsiem:latest"
}

resource "docker_image" "filebeat" {
  name = "docker.elastic.co/beats/filebeat:7.4.0"
}


resource "docker_image" "suricata" {
  name = "defenxor/suricata:1710"
}




resource "docker_container" "elasticsearch" {
  image = docker_image.elasticsearch.latest
  name  = "elasticsearch"
  networks_advanced {
    name         = "network_test"
  }
  hostname = "elasticsearch"
  ports {
    internal = 9200
    external = 9200
  }
  env = ["discovery.type=single-node",
    "ES_JAVA_OPTS=-Xms256m -Xmx256m",
    "cluster.routing.allocation.disk.threshold_enabled=false",
    "xpack.security.enabled=false",
    "xpack.monitoring.enabled=false",
    "xpack.ml.enabled=false",
    "xpack.graph.enabled=false",
    "xpack.watcher.enabled=false",
    "http.cors.enabled=true",
  "http.cors.allow-origin='/https?://localhost(:[0-9]+)?/'"]
  volumes {
    container_path = "/usr/share/elasticsearch/data"
    volume_name      = "es-data"
  }
}


resource "docker_container" "logstash" {
  image = docker_image.logstash.latest
  name  = "logstash"
  networks_advanced {
    name         = "network_test"
  }
  hostname = "logstash"
  env      = ["XPACK_MONITORING_ENABLED=false"]
  volumes {
    container_path = "/etc/logstash/conf.d"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/logstash/conf.d"
  }
  volumes {
    container_path = "/etc/logstash/index-template.d"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/logstash/index-template.d/es7"
  }
}



resource "docker_container" "kibana" {
  image = docker_image.kibana.latest
  name  = "kibana"
  networks_advanced {
    name         = "network_test"
  }
  hostname = "kibana"
  ports {
    internal = 5601
    external = 5601
  }
  env = ["XPACK_MONITORING_ENABLED=false"]
}

resource "docker_container" "dsiem" {
  image = docker_image.dsiem.latest
  name  = "dsiem"

  networks_advanced {
    name         = "network_test"
  }
  hostname = "dsiem"
  ports {
    internal = 8080
    external = 8080
  }
  env = ["DSIEM_WEB_ESURL=http://elasticsearch:9200",
  "DSIEM_WEB_KBNURL=http://kibana:5601"]
  volumes {
    container_path = "/dsiem/logs"
    volume_name      = "dsiem-log"
  }
}

resource "docker_container" "filebeat-es" {
  image = docker_image.filebeat.latest
  name  = "filebeat-es"
  user = "root"
  networks_advanced {
    name         = "network_test"
  }
  hostname = "filebeat-es"
  volumes {
    container_path = "/usr/share/filebeat/filebeat.yml"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/filebeat-es/filebeat.yml"
  }
  volumes {
    container_path = "/usr/share/filebeat/fields.yml"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/filebeat-es/fields.yml"
  }
  volumes {
    container_path = "/usr/share/filebeat/module"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/filebeat-es/module"
  }
  volumes {
    container_path = "/usr/share/filebeat/modules.d"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/filebeat-es/modules.d"
  }

  volumes {
    container_path = "/usr/share/filebeat/data"
    volume_name      = "filebeat-es-data"
  }
  volumes {
    container_path = "/var/log/dsiem"
    volume_name      = "dsiem-log"
  }
}

resource "docker_container" "filebeat" {
  image = docker_image.filebeat.latest
  name  = "filebeat"
  user = "root"
  networks_advanced {
    name         = "network_test"
  }
  hostname = "filebeat"
  volumes {
    container_path = "/usr/share/filebeat/data"
    volume_name      = "filebeat-data"
  }
  volumes {
    container_path = "/usr/share/filebeat/filebeat.yml"
    host_path      = "/home/gianluca/docs/Uni/classnotes/tesi/dsiem/deployments/docker/conf/filebeat/filebeat.yml"
  }
  volumes {
    volume_name      = "dsiem-log"
    container_path = "/var/log/dsiem"
  }
  volumes {
    volume_name      = "suricata-log"
    container_path = "/var/log/suricata"
  }
}


resource "docker_container" "suricata" {
  image = docker_image.suricata.latest
  name  = "suricata"

  networks_advanced {
    name         = "network_test"
  }
  hostname = "suricata"
  volumes {
    volume_name = "suricata-log"
    container_path      = "/var/log/suricata"
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
