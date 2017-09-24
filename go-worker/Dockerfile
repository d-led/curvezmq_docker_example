FROM golang:1.9

RUN apt-get update && apt-get install -y libzmq3-dev libsodium-dev

ENV GOMAXPROCS 4

RUN go get github.com/pebbe/zmq4

COPY . .

RUN go build main.go

CMD ./main
