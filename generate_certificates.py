#!/usr/bin/env python

# pip install pyzmq

import zmq.auth
import sys
import os

if __name__ == '__main__':
    peers = ['pony-server']

    for name in peers:
        public_file, secret_file = zmq.auth.create_certificates(name, "tmp")
        print("Generated: "+str(public_file)+", "+str(secret_file))
