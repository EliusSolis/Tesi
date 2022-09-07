#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER frontend;
    ALTER USER frontend PASSWORD 'frontend';
    GRANT ALL PRIVILEGES ON DATABASE webapp TO frontend;
EOSQL

psql -v ON_ERROR_STOP=1 --username "frontend" --dbname "webapp" <<-EOSQL
    CREATE TABLE account (
        username VARCHAR(25) PRIMARY KEY,
        password VARCHAR(25) NOT NULL
    );

    INSERT INTO account (username, password) VALUES ('MarioRossi', 'uncrAckab13');
    INSERT INTO account (username, password) VALUES ('LuigiVerdi', 'secretpa55w0rd');
    INSERT INTO account (username, password) VALUES ('FabioBianchi', 'th30nly0n3');
    INSERT INTO account (username, password) VALUES ('TerenceHill', 'l0chiamavano3ita');
    INSERT INTO account (username, password) VALUES ('BeppeVessicchio', 'SanR3m0');

    CREATE TABLE product (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        price REAL NOT NULL
    );

    INSERT INTO product (name, price) VALUES ('Coca-Cola', '1.29');
    INSERT INTO product (name, price) VALUES ('Nutella', '2.49');
    INSERT INTO product (name, price) VALUES ('Gocciole', '1.85');
    INSERT INTO product (name, price) VALUES ('Penna a sfera', '0.39');
EOSQL
