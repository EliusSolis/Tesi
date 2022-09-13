FROM docker.elastic.co/beats/filebeat:7.17.6
COPY --chown=root:filebeat filebeat.yml /usr/share/filebeat/filebeat.yml

RUN yum install -y iproute
