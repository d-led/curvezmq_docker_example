#!/usr/bin/env python

# pip install pyzmq

import zmq.auth
import sys
import os

if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.argv[1:] = ["server"]

    where = "certificates"

    if not os.path.exists(where):
        os.mkdir(where)


    peers = ['server']

    for name in peers:
        public_file, secret_file = zmq.auth.create_certificates(where, sys.argv[1])
        print("Generated: "+str(public_file)+", "+str(secret_file))
