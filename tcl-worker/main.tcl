package require zmq

proc load_certificate {filename} {
    return { {} {} }
}

# zmq context context ;# crashes

# zmq socket push context PUSH
# push connect "tcp://pony-server:7777"
# # push configure CURVE_PUBLICKEY $client_public
# # push configure CURVE_SECRETKEY $client_secret
# # push configure CURVE_SERVERKEY $server_public

# zmq socket pull context PUSH
# # pull configure CURVE_PUBLICKEY $client_public
# # pull configure CURVE_SECRETKEY $client_secret
# # pull configure CURVE_SERVERKEY $server_public
# pull connect "tcp://pony-server:7777"

# while {true} {
#     set rpoll_set [zmq poll {{pull {POLLIN}}} 20000]

#     if {[llength $rpoll_set] == 0} {
#         break
#     }

#     set msg [pull recv]

#     puts "Tcl worker received: $msg"

#     push send "Tcl worker says: $msg"
# }

# puts "Exiting the Tcl worker"
