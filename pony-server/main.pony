// docker build --pull -t ponydock .
// docker run ponydock

actor Main
    new create(env: Env) =>
        let printer = Printer(env)
        printer.print("starting the server")

        let server_key = KeyParser(env, printer, "server.key_secret").key()
        printer.print("server public key: "+server_key.public)
        let sender = Sender(env, printer, server_key)
        let receiver = Receiver(env, printer)

        // sleep for a while
        let delay: I32 = 10
        @sleep[I32](delay)
        sender.dispose()
        receiver.dispose()