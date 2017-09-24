package main

import (
    "fmt"
    zmq "github.com/pebbe/zmq4"
    "io/ioutil"
    "os"
    "regexp"
    "time"
)

func main() {
    // exit after some seconds (for demo purposes)
    go func() {
        time.Sleep(20 * time.Second)
        fmt.Println("Exiting the go worker")
        os.Exit(0)
    }()

    fmt.Println("Starting go worker")

    client_public, client_secret, err := readKeysFrom("client.key_secret")
    panicIfError(err)

    server_public, _, err := readKeysFrom("server.key")
    panicIfError(err)

    push, _ := zmq.NewSocket(zmq.PUSH)
    push.ClientAuthCurve(server_public, client_public, client_secret)
    push.Connect("tcp://pony-server:7778")

    pull, _ := zmq.NewSocket(zmq.PULL)
    pull.ClientAuthCurve(server_public, client_public, client_secret)
    pull.Connect("tcp://pony-server:7777")

    for {
        message, err := pull.Recv(0)
        panicIfError(err)
        fmt.Println("Go worker received:", message)
        _, err = push.Send("Go worker says: "+message, 0)
        panicIfError(err)
    }
}

func panicIfError(err error) {
    if err != nil {
        fmt.Println("Go worker ERROR: ", err)
        panic(err)
    }
}

func readKeysFrom(filename string) (string, string, error) {
    secret_regex, err := regexp.Compile("secret-key\\s*\\=\\s*\"(\\S+?)\"")
    if err != nil {
        return "", "", err
    }

    public_regex, err := regexp.Compile("public-key\\s*\\=\\s*\"(\\S+?)\"")
    if err != nil {
        return "", "", err
    }

    b, err := ioutil.ReadFile(filename)
    if err != nil {
        return "", "", err
    }

    var secret = ""

    secret_found := secret_regex.FindSubmatch(b)
    if secret_found != nil {
        secret = string(secret_found[1])
    }

    var public = ""

    public_found := public_regex.FindSubmatch(b)
    if public_found != nil {
        public = string(public_found[1])
    }

    return public, secret, nil
}
