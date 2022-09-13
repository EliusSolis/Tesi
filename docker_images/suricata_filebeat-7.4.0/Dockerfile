FROM ubuntu

RUN apt update && apt upgrade -y
# Utilities for later use
RUN apt install -y software-properties-common wget curl apt-transport-https unzip inetutils-ping iproute2 iptables

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

# Installing filebeat 7.4.2
# RUN wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.2-amd64.deb && \
#     dpkg -i filebeat-7.4.2-amd64.deb

# Installing filebeat 7.17
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
RUN apt update && apt install filebeat -y


# Filebeat config to work with dsiem and suricata
#RUN wget https://raw.githubusercontent.com/defenxor/dsiem/master/deployments/docker/conf/filebeat/filebeat.yml \
#    -O /etc/filebeat/filebeat.yml
ADD filebeat.yml /etc/filebeat/filebeat.yml
RUN chown root /etc/filebeat/filebeat.yml && \
    chmod 0644 /etc/filebeat/filebeat.yml

RUN update-rc.d filebeat defaults 95 10

# Start filebeat and dsiem
CMD service filebeat start && service suricata start
