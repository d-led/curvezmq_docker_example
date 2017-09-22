#!/usr/bin/env bash

echo --=== generating the certificates ===--
./generate_certificates.py

echo --=== building and starting the containers ===--
docker-compose up --build
