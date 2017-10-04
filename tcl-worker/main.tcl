package require zmq

proc load_certificate {filename} {
    set public_key {}
    set secret_key {}

    set file [open $filename r]
    set text [read $file]
    close $file

    regexp {.*?secret-key\s*\=\s*\"(\S+?)\".*} $text -> secret_key
    regexp {.*?public-key\s*\=\s*\"(\S+?)\".*} $text -> public_key

    return [list $public_key $secret_key]
}

lassign [load_certificate "client.key_secret"] client_public client_secret
lassign [load_certificate "server.key"] server_public server_secret

zmq context context

zmq socket pull_ context PULL
pull_ configure CURVE_PUBLICKEY $client_public
pull_ configure CURVE_SECRETKEY $client_secret
pull_ configure CURVE_SERVERKEY $server_public
pull_ connect "tcp://pony-server:7777"

zmq socket push_ context PUSH
push_ configure CURVE_PUBLICKEY $client_public
push_ configure CURVE_SECRETKEY $client_secret
push_ configure CURVE_SERVERKEY $server_public
push_ connect "tcp://pony-server:7778"


puts "Starting Tcl worker"

while {true} {
    set rpoll_set [zmq poll {{pull_ {POLLIN}}} 20000]

    if {[llength $rpoll_set] == 0} {
        break
    }
    set msg [pull_ recv]

    puts "Tcl worker received: $msg"

    push_ send "Tcl worker says: $msg"

    flush stdout
}

pull_ close
push_ close
context term

puts "Exiting the Tcl worker"
