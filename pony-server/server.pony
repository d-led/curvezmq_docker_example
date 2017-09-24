use zmq = "zmq"
use net = "net"

actor Sender is zmq.SocketNotifiableActor
    let push: zmq.Socket
    let printer: Printer

    new create(env: Env,printer': Printer,server_key: Key val) =>
        printer = printer'
        push = zmq.Socket(zmq.PUSH, zmq.SocketNotifyActor(this))

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

    new create(env: Env, printer': Printer) =>
        printer = printer'
        pull = zmq.Socket(zmq.PULL, zmq.SocketNotifyActor(this))

        match env.root | let root: AmbientAuth =>
            pull(zmq.ConnectTCP(net.NetAuth(root), "127.0.0.1", "7777"))
            printer.print("starting to wait for responses")
        else
            printer.print("ERROR: could not create Receiver")
        end


    be received(socket: zmq.Socket, peer: zmq.SocketPeer, message: zmq.Message) =>
        printer.print("Received: " + message.string())

    be dispose() =>
        pull.dispose()
