FROM docker.elastic.co/beats/filebeat:8.3.3


COPY --chown=root filebeat.yml /usr/share/filebeat/filebeat.yml
COPY --chown=root fields.yml /usr/share/filebeat/fields.yml
ADD module/ /usr/share/filebeat/module
ADD modules.d /usr/share/modules.d
