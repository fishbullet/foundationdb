FROM ubuntu:16.04

RUN apt-get update && apt-get install --fix-missing --yes wget golang python git mono-complete make default-jre m4

RUN wget https://www.foundationdb.org/downloads/6.0.15/ubuntu/installers/foundationdb-clients_6.0.15-1_amd64.deb
RUN dpkg -i foundationdb-clients_6.0.15-1_amd64.deb

ENV GOPATH /usr/bin

RUN wget https://raw.githubusercontent.com/apple/foundationdb/master/bindings/go/fdb-go-install.sh

RUN chmod +x /fdb-go-install.sh && /fdb-go-install.sh install --fdbver 6.0.15

RUN mkdir -p app

COPY app/ app

COPY conf/foundationdb.conf /etc/foundationdb/


