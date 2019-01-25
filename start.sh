#!/bin/bash

FDB_LISTEN_ADDR="0.0.0.0"
FDB_PUBLIC_ADDR="*" # set public ip address of the server here

dpkg -i foundationdb-server_6.0.15-1_amd64.deb

sed -i "s/^listen_address.*/listen_address = ${FDB_LISTEN_ADDR}:4500/" /etc/foundationdb/foundationdb.conf && \
    cp -r /etc/foundationdb /etc/foundationdb.default
sed -i "s/^public_address.*/public_address = ${FDB_PUBLIC_ADDR}:4500/" /etc/foundationdb/foundationdb.conf && \
    cp -r /etc/foundationdb /etc/foundationdb.default

fdbcli
