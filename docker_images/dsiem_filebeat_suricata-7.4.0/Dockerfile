FROM ubuntu

RUN apt update && apt upgrade -y
# Utilities for later use
RUN apt install -y software-properties-common wget curl apt-transport-https unzip

# Add suricata repo and install it
RUN add-apt-repository -y ppa:oisf/suricata-stable
RUN apt update && apt install -y suricata

# Suricata config
ADD suricata.yaml /etc/suricata/suricata.yaml
ADD custom.rules /var/lib/suricata/rules/custom.rules
ADD suricata-default-config /etc/default/suricata

# Enabling open emerging threats ruleset
RUN suricata-update
RUN suricata-update update-sources
RUN suricata-update enable-source et/open
RUN suricata-update

# Installing filebeat 7.4.0
RUN wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.2-amd64.deb
RUN dpkg -i filebeat-7.4.2-amd64.deb


# Filebeat config to work with dsiem and suricata
#RUN wget https://raw.githubusercontent.com/defenxor/dsiem/master/deployments/docker/conf/filebeat/filebeat.yml \
#    -O /etc/filebeat/filebeat.yml
ADD filebeat.yml /etc/filebeat/filebeat.yml
RUN chown root /etc/filebeat/filebeat.yml
RUN chmod 0644 /etc/filebeat/filebeat.yml


# getting dsiem

ENV DSIEM_DIR=/var/dsiem
RUN mkdir -p $DSIEM_DIR && \
    wget https://github.com/defenxor/dsiem/releases/latest/download/dsiem-server_linux_amd64.zip -O /tmp/dsiem.zip && \
    unzip /tmp/dsiem.zip -d $DSIEM_DIR && rm -rf /tmp/dsiem.zip

WORKDIR $DSIEM_DIR

# getting dsiem tools
RUN wget https://github.com/defenxor/dsiem/releases/latest/download/dsiem-tools_linux_amd64.zip && \
    mkdir dsiem-tools && \
    unzip dsiem-tools_linux_amd64.zip -d dsiem-tools

# Let the web UI know how to reach Elasticsearch and Kibana
ADD esconfig.json ./web/dist/assets/config/esconfig.json

# Importing kibana dashboard
RUN wget https://raw.githubusercontent.com/defenxor/dsiem/master/scripts/kbndashboard-import.sh && \
    chmod +x kbndashboard-import.sh
RUN wget https://raw.githubusercontent.com/defenxor/dsiem/master/deployments/kibana/dashboard-siem.json
# RUN ./kbndashboard-import.sh kibana dashboard-siem.json

# dsiem port
EXPOSE 8080

# Start filebeat and dsiem
CMD service filebeat start && service suricata start && ./dsiem serve
