FROM ubuntu:16.04

RUN apt-get update && apt-get install --fix-missing --yes wget vim python 

RUN wget https://www.foundationdb.org/downloads/6.0.15/ubuntu/installers/foundationdb-clients_6.0.15-1_amd64.deb
RUN dpkg -i foundationdb-clients_6.0.15-1_amd64.deb
RUN wget https://www.foundationdb.org/downloads/6.0.15/ubuntu/installers/foundationdb-server_6.0.15-1_amd64.deb

COPY start.sh .
