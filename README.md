# curvezmq_docker_example

Experimenting with [CurveZMQ](http://curvezmq.org) in different languages.

The core question of the experiment is to see, whether different languages can interoperate securely via ZeroMQ.

Build & example output: see [![Build Status](https://travis-ci.org/d-led/curvezmq_docker_example.svg?branch=master)](https://travis-ci.org/d-led/curvezmq_docker_example)

## Libraries

- [pyzmq](http://pyzmq.readthedocs.io/en/latest/) key generation, worker
- [pony-zmq](https://github.com/jemc/pony-zmq) server, worker
- [go: zmq4](https://github.com/pebbe/zmq4) worker
- [jeromq](https://github.com/zeromq/jeromq) worker

## Architecture

### Deployment

- for simplicity: as a Docker Compose config
- keys generated via a simple python script: [generate_certificates.py](generate_certificates.py)
- server public key distribution via simple copying into the containers

### Communication

- ZeroMQ communication via TCP + CurveZMQ ([Stonehouse pattern](http://hintjens.com/blog:49#toc5))
- Requests sent on port 7777, and returned on 7778
- The push socket does task distribution to the workers ([Divide and conquer pattern](http://zguide.zeromq.org/page:all#Divide-and-Conquer))
- Timeouts are (currently) used to stop the demo after the server sends a finite amount of requests

### Pony Server

- `Sender` actor to send sample requests at regular intervals on port `7777`
- `Receiver` actor to receive responses on port `7778`
- `Printer` actor to serialize printing to console
- `Worker` actor to test `pony-zmq` in a round-trip (pulling on port `7777`, pushing on port `7778`)

### Python Worker

- polling with a timeout
- pulling on port `7777`, pushing on port `7778`

### Go Worker

- `7777`/`7778`

### Groovy Worker

- preparing dependencies for jzmq failed &rarr; using jeromq
- `7777`/`7778`
