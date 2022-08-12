FROM docker.elastic.co/beats/filebeat:8.3.3

USER root

COPY --chown=root filebeat.yml /usr/share/filebeat/filebeat.yml
COPY --chown=root fields.yml /usr/share/filebeat/fields.yml
RUN chmod 0644 /usr/share/filebeat/filebeat.yml

ADD module/ /usr/share/filebeat/module
ADD modules.d /usr/share/modules.d
