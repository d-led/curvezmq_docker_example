// docker build --pull -t ponydock .
// docker run ponydock

use "time"

actor Main
    new create(env: Env) =>
        let printer = Printer(env)
        printer.print("Starting Pony server")

        let server_key = KeyParser(env, printer, "server.key_secret").key()
        printer.print("server public key: "+server_key.public)
        let receiver = Receiver(env, printer, server_key)
        let sender = Sender(env, printer, server_key)

        printer.print("Starting Pony worker")
        let worker_key = KeyParser(env, printer, "client.key_secret").key()
        let worker = Worker(env, printer, worker_key, server_key.public)

        // send tasks
        let timers = Timers
        let timer = Timer(NumberGenerator(env, sender), 0, 1_000_000_000)
        timers(consume timer)

        // sleep for a while
        let delay: I32 = 22
        @sleep[I32](delay)
        sender.dispose()
        receiver.dispose()
        worker.dispose()
        timers.dispose()

class NumberGenerator is TimerNotify
  let _env: Env
  var _counter: U64
  var _sender: Sender

  new iso create(env: Env, sender: Sender) =>
    _counter = 0
    _env = env
    _sender = sender

  fun ref _next(): String =>
    _counter = _counter + 1
    "Ping #" + _counter.string()

  fun ref apply(timer: Timer, count: U64): Bool =>
    _sender.ping(_next())
    true
