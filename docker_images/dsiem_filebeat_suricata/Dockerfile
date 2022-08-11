FROM ubuntu

RUN apt-get update && apt-get upgrade -y 
# Utilities for later use
RUN apt-get install -y software-properties-common wget apt-transport-https unzip


# Add suricata repo and install it
RUN add-apt-repository -y ppa:oisf/suricata-stable
RUN apt update && apt install -y suricata

# Suricata config
ADD suricata.yaml /etc/suricata/suricata.yaml
ADD custom.rules /var/lib/suricata/rules/custom.rules

# Add Filebeat repo
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list

# Installing Filebeat
RUN apt-get update && apt-get install -y filebeat

# Filebeat config to work with dsiem and suricata
RUN wget https://raw.githubusercontent.com/defenxor/dsiem/master/deployments/docker/conf/filebeat/filebeat.yml \
    -O /etc/filebeat/filebeat.yml
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

# dsiem port
EXPOSE 8080

# Importing kibana dashboard
# RUN ./scripts/kbndashboard-import.sh  http://kibana:5601 ./deployments/kibana/dashboard-siem.json

# Start filebeat and dsiem
CMD service filebeat start && service suricata start && ./dsiem serve
