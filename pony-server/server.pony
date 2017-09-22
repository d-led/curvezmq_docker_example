use zmq = "zmq"
use net = "net"

actor Sender is zmq.SocketNotifiableActor
    let push: zmq.Socket
    let printer: Printer

    new create(env: Env,printer': Printer,server_key: Key val) =>
        printer = printer'
        push = zmq.Socket(zmq.PUSH, zmq.SocketNotifyActor(this))

        match env.root | let root: AmbientAuth =>
            push(zmq.BindTCP(net.NetAuth(root), "localhost", "7777"))

            printer.print("starting to push values")
            push.send(recover zmq.Message.>push("hi") end)
            let delay: I32 = 2
            @sleep[I32](delay)
            push.dispose()
        else
            printer.print("ERROR: could not create Sender")
        end


actor Receiver is zmq.SocketNotifiableActor
    let pull: zmq.Socket
    let printer: Printer

    new create(env: Env, printer': Printer) =>
        printer = printer'
        pull = zmq.Socket(zmq.PULL, zmq.SocketNotifyActor(this))

        match env.root | let root: AmbientAuth =>
            pull(zmq.ConnectTCP(net.NetAuth(root), "localhost", "7777"))
            printer.print("starting to wait for responses")
        else
            printer.print("ERROR: could not create Receiver")
        end


    be received(socket: zmq.Socket, peer: zmq.SocketPeer, message: zmq.Message) =>
        printer.print("Received: " + message.string())
        let delay: I32 = 2
        @sleep[I32](delay)
        pull.dispose()