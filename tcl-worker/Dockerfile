FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
            tcl8.6 \
            tcl8.6-dev \
            tcllib \
            tcl-thread \
            uuid-dev \
            git \
            libzmq3-dev \
            libsodium-dev \
            && apt-get clean

RUN git clone http://github.com/andreas-kupries/critcl \
      && cd critcl \
      && tclsh ./build.tcl install

RUN git clone https://github.com/jdc8/tclzmq.git \
      && cd tclzmq \
      && tclsh build.tcl install

COPY . .

CMD tclsh main.tcl
