use zmq = "zmq"
use net = "net"


actor Worker is zmq.SocketNotifiableActor
    let push: zmq.Socket
    let pull: zmq.Socket
    let printer: Printer

    new create(env: Env, printer': Printer, key: Key val, server_public_key: String) =>
        printer = printer'

        pull = zmq.Socket(zmq.PULL, zmq.SocketNotifyActor(this))
        pull.set(zmq.CurvePublicKey(key.public))
        pull.set(zmq.CurveSecretKey(key.secret))
        pull.set(zmq.CurvePublicKeyOfServer(server_public_key))

        push = zmq.Socket(zmq.PUSH, zmq.SocketNotifyActor(this))
        push.set(zmq.CurvePublicKey(key.public))
        push.set(zmq.CurveSecretKey(key.secret))
        push.set(zmq.CurvePublicKeyOfServer(server_public_key))


        match env.root | let root: AmbientAuth =>
            pull(zmq.ConnectTCP(net.NetAuth(root), "127.0.0.1", "7777"))
        else
            printer.print("ERROR: could not create worker Receiver")
        end

        match env.root | let root: AmbientAuth =>
            push(zmq.ConnectTCP(net.NetAuth(root), "127.0.0.1", "7778"))
        else
            printer.print("ERROR: could not create worker Sender")
        end



    be received(socket: zmq.Socket, peer: zmq.SocketPeer, message: zmq.Message) =>
        printer.print("Pony Worker received: " + message.string())
        let first_frame = try message(0)? else "" end
        push.send(recover zmq.Message.>push("Pony worker says: "+first_frame.string()) end)

    be dispose() =>
        pull.dispose()
        push.dispose()
