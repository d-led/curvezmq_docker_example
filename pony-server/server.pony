use zmq = "zmq"
use net = "net"

actor Sender is zmq.SocketNotifiableActor
    let push: zmq.Socket
    let printer: Printer

    new create(env: Env,printer': Printer, server_key: Key val) =>
        printer = printer'
        push = zmq.Socket(zmq.PUSH, zmq.SocketNotifyActor(this))

        push.set(zmq.CurvePublicKey(server_key.public))
        push.set(zmq.CurveSecretKey(server_key.secret))
        push.set(zmq.CurveAsServer(true))

        match env.root | let root: AmbientAuth =>
            push(zmq.BindTCP(net.NetAuth(root), "0.0.0.0", "7777"))

            printer.print("starting to push values")
            push.send(recover zmq.Message.>push("hi") end)
        else
            printer.print("ERROR: could not create Sender")
        end

    be dispose() =>
        push.dispose()


actor Receiver is zmq.SocketNotifiableActor
    let pull: zmq.Socket
    let printer: Printer

    new create(env: Env, printer': Printer, server_key: Key val) =>
        printer = printer'
        pull = zmq.Socket(zmq.PULL, zmq.SocketNotifyActor(this))
        pull.set(zmq.CurvePublicKey(server_key.public))
        pull.set(zmq.CurveSecretKey(server_key.secret))
        pull.set(zmq.CurveAsServer(true))

        match env.root | let root: AmbientAuth =>
            pull(zmq.BindTCP(net.NetAuth(root), "0.0.0.0", "7778"))
            printer.print("starting to wait for responses")
        else
            printer.print("ERROR: could not create Receiver")
        end


    be received(socket: zmq.Socket, peer: zmq.SocketPeer, message: zmq.Message) =>
        printer.print("Pony Server received: " + message.string())

    be dispose() =>
        pull.dispose()
