#!/usr/bin/env bash

echo --=== generating the keys ===--
./generate_certificates.py

echo --=== distributing the keys ===--
cp go-server/server.key python-worker/server.key
cp go-server/server.key groovy-worker/server.key
cp go-server/server.key tcl-worker/server.key
cp go-server/server.key elixir-worker/priv/server.key

echo --=== building and starting the containers ===--
# docker-compose build
docker-compose up --build
