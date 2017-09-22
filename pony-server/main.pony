// docker build --pull -t ponydock .
// docker run ponydock

actor Main
    new create(env: Env) =>
        let printer = Printer(env)
        printer.print("starting the server")

        let sender = Sender(env, printer)
        let receiver = Receiver(env, printer)
