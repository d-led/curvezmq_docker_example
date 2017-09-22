// docker build --pull -t ponydock .
// docker run ponydock

use zmq = "zmq"

actor Main
    new create(env: Env) =>
        let printer = Printer(env)
        printer.print("starting the server")
