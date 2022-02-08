FROM ponylang/ponyc:release

RUN apt-get update && \
    apt-get -y install build-essential libpcre2-dev libsodium-dev

RUN ponyc --version

COPY corral.json lock.json /src/main/
RUN corral fetch

COPY . /src/main/
WORKDIR /src/main
RUN corral run -- ponyc
CMD ./main
