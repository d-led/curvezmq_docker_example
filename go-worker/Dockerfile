FROM golang:1.17

RUN apt-get update && apt-get install -y libzmq3-dev libsodium-dev

WORKDIR /usr/src/main

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN go build -o main

CMD ./main
