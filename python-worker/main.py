#!/usr/bin/env python

# pip install pyzmq

import sys
import os

import zmq
import zmq.auth
from zmq.auth.thread import ThreadAuthenticator


if __name__ == '__main__':
    base_dir = os.path.dirname(__file__)

    client_secret_file = os.path.join(base_dir, "client.key_secret")
    client_public, client_secret = zmq.auth.load_certificate(client_secret_file)

    server_public_file = os.path.join(base_dir, "server.key")
    server_public, _ = zmq.auth.load_certificate(server_public_file)

    ctx = zmq.Context.instance()

    push = ctx.socket(zmq.PUSH)
    push.curve_secretkey = client_secret
    push.curve_publickey = client_public
    push.curve_serverkey = server_public
    push.connect('tcp://pony-server:7778')

    pull = ctx.socket(zmq.PULL)
    pull.curve_secretkey = client_secret
    pull.curve_publickey = client_public
    pull.curve_serverkey = server_public
    pull.connect('tcp://pony-server:7777')

    while True:
        if pull.poll(20000):
            msg = pull.recv()
            print("Python worker received: "+msg.decode('ascii'))
            sys.stdout.flush()
            push.send(b"Python worker says: " + msg)
        else:
            print("Exiting the python worker")
            break
