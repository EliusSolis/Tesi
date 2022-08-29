FROM docker.elastic.co/logstash/logstash:7.4.0

# loading custom config
RUN rm -f /usr/share/logstash/pipeline/logstash.conf 

ADD pipeline /usr/share/logstash/pipeline
ADD index-template.d/es7 /etc/logstash/index-template.d

WORKDIR /usr/share/logstash

RUN bin/logstash-plugin install logstash-filter-prune && \
    bin/logstash-plugin install logstash-filter-uuid

EXPOSE 5400

CMD logstash -f ./pipeline
