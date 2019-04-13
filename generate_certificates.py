#!/usr/bin/env python

# pip install pyzmq

import zmq.auth
import sys
import os

if __name__ == '__main__':
    peers = [
        ['pony-server', 'server'],
        ['pony-server', 'client'],
        ['python-worker', 'client'],
        # ['go-server', 'server'],
        ['go-worker', 'client'],
        ['groovy-worker', 'client'],
        ['tcl-worker', 'client'],
        ['elixir-worker/priv', 'client'],
    ]

    for names in peers:
        public_file, secret_file = zmq.auth.create_certificates(names[0], names[1])
        print("Generated: "+str(public_file)+", "+str(secret_file))
