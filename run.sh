#!/usr/bin/env bash

echo --=== generating the keys ===--
./generate_certificates.py

echo --=== distributing the keys ===--
cp pony-server/server.key python-worker/server.key
cp pony-server/server.key go-worker/server.key
cp pony-server/server.key groovy-worker/server.key
cp pony-server/server.key tcl-worker/server.key

echo --=== building and starting the containers ===--
# docker-compose build
docker-compose up --build
