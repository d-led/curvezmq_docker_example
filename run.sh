#!/usr/bin/env bash

echo --=== generating the certificates ===--
./generate_certificates.py
cp pony-server/server.key server.key

echo --=== building and starting the containers ===--
docker-compose up --build
