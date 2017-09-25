import java.nio.charset.Charset

import org.zeromq.*
import zmq.*

class App {

    static void main(String[] args) {
        new App().run()
        println "Exiting the groovy worker"
    }

    def run() {
        def client_key = readCertificate('client.key_secret')
        def server_key = readCertificate('server.key')

        def ctx = new ZContext()

        def push = ctx.createSocket(ZMQ.PUSH)
        push.setCurvePublicKey(client_key.public_)
        push.setCurveSecretKey(client_key.secret_)
        push.setCurveServerKey(server_key.public_)
        push.connect("tcp://pony-server:7778")
        def pull = ctx.createSocket(ZMQ.PULL)
        pull.setCurvePublicKey(client_key.public_)
        pull.setCurveSecretKey(client_key.secret_)
        pull.setCurveServerKey(server_key.public_)
        pull.connect("tcp://pony-server:7777")

        def poller = ctx.createPoller(1)
        poller.register(pull, ZMQ.Poller.POLLIN)

        while (!Thread.currentThread().isInterrupted()) {
            if (poller.poll(20000 /*ms*/)<1) {
                break
            }

            if (poller.pollin(0)) {
                def bytes = pull.recv(0)
                def message = new String(bytes, "ASCII")
                println("Groovy worker received: "+message)
                push.send("Groovy worker says: "+message)
            }
        }
    }

    def readCertificate(filename) {
        def text = new File(filename).getText('ASCII')
        def secret_match = text =~ /(?s).*?secret-key\s*\=\s*\"(\S+?)\".*/
        def secret = secret_match.matches() ? secret_match[0][1] : ''
        def public_match = text =~ /(?s).*?public-key\s*\=\s*\"(\S+?)\".*/
        def public_ = public_match.matches() ? public_match[0][1] : ''

        [
            secret_: secret.getBytes(),
            public_: public_.getBytes()
        ]
    }
}
