// stable fetch
// stable env ponyc && ./pony-benchmark && ./pony-benchmark secure
use "time"
use zmq = "zmq"
use net = "net"


actor Main
    new create(env: Env) =>
        let secure = try env.args(1)?.compare("secure") == Equal else false end
        env.out.print("Secure: "+secure.string())
        PushPull.create(env, 100_000, secure)


actor PushPull
    let _env : Env
    let sender: Sender
    let receiver: Receiver

    new create(env: Env, count: U64, secure: Bool) =>
        _env = env
        sender = Sender.create(env, count, secure)
        receiver = Receiver.create(env, count, secure, {() =>
            // stop the sender when done
            sender.dispose()
            env.out.print("done!")
        })
        sender.start()

    be abort() =>
        _env.out.print("aborting")
        sender.dispose()
        receiver.dispose()


actor Sender is zmq.SocketNotifiableActor
    let push: zmq.Socket
    let _count: U64

    new create(env: Env, count: U64, secure: Bool) =>
        push = zmq.Socket(zmq.PUSH, zmq.SocketNotifyActor(this))
        _count = count

        if secure then
            push.set(zmq.CurvePublicKey("Er$Ck6GTQ6g5kkMxPuNLTY1o?])P1ZT=G&<>g$?t"))
            push.set(zmq.CurveSecretKey("l=Db6.oKia?]l[@*FtN$GDFWI]hO=H?#K]#W*^BP"))
            push.set(zmq.CurveAsServer(true))
        end

        match env.root | let root: AmbientAuth =>
            push(zmq.BindTCP(net.NetAuth(root), "0.0.0.0", "8888"))

            env.out.print("starting to push values")
        else
            env.out.print("ERROR: could not create Sender")
        end

    be start() =>
        // create the load
        var i: U64 = 0
        while i < _count do
            ping()
            i = i + 1
        end


    fun ping() =>
        push.send(recover zmq.Message.>push("hello") end)


    be dispose() =>
        push.dispose()


actor Receiver is zmq.SocketNotifiableActor
    let pull: zmq.Socket
    let _sw: Stopwatch
    let _env : Env
    let _count: U64
    var _received: U64 = 0
    let _done: {()} val

    new create(env: Env, count: U64, secure: Bool, done: {()} val) =>
        _env = env
        _count = count
        _done = done

        pull = zmq.Socket(zmq.PULL, zmq.SocketNotifyActor(this))


        if secure then
            pull.set(zmq.CurvePublicKey("U%Y&7ZvyHoL4Fq1^gefag(}pd.</X2^=(sMD}>Uu"))
            pull.set(zmq.CurveSecretKey("uuk(^(>fvQ-U?Gf=4%a5jUd6T59%uYRUZNTDE1[N"))
            pull.set(zmq.CurvePublicKeyOfServer("Er$Ck6GTQ6g5kkMxPuNLTY1o?])P1ZT=G&<>g$?t"))
        end


        match env.root | let root: AmbientAuth =>
            pull(zmq.ConnectTCP(net.NetAuth(root), "127.0.0.1", "8888"))
            env.out.print("starting to wait for responses")
        else
            env.out.print("ERROR: could not create Receiver")
        end

        _sw = Stopwatch.create()


    be received(socket: zmq.Socket, peer: zmq.SocketPeer, message: zmq.Message) =>
        _received = _received + 1
        if _received >= _count then
            dispose()
        end

    be dispose() =>
        let seconds = _sw.elapsedSeconds()
        _env.out.print("sent/received "
            + _received.string()
            + " messages in " + seconds.string() + "s"
            + "( " + (_received.f64()/seconds).string() + "/s)"
        )
        _done()
        pull.dispose()


class Stopwatch
    var _t1: U64

    new create() =>
        _t1 = Time.nanos()

    fun elapsedSeconds() : F64 =>
        let t2: U64 = Time.nanos()
        (t2-_t1).f64()/1000000000.0
