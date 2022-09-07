FROM postgres

RUN apt update && apt install -y iproute2

ADD populate.sh /docker-entrypoint-initdb.d/
