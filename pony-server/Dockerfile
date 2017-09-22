FROM ponylang/ponyc

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "D401AB61 DBE1D0A2" && \
    echo "deb http://dl.bintray.com/pony-language/pony-stable-debian /" | tee -a /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install pony-stable libsodium-dev

# tmp.key* must be generated before building
COPY . /src/main/
WORKDIR /src/main
RUN stable fetch
RUN stable env ponyc

CMD ./main
