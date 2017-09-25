FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
            tcl8.6 \
            tcl8.6-dev \
            tcllib \
            tcl-thread \
            critcl \
            uuid-dev \
            git \
            libzmq3-dev \
            libsodium-dev \
            && apt-get clean


RUN git clone https://github.com/d-led/tclzmq.git

RUN cd tclzmq && tclsh build.tcl debug

COPY main.tcl .

CMD tclsh main.tcl
