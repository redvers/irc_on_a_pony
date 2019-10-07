use "debug"
use "net"

actor Main
  new create(env: Env) =>
    env.out.print("Hello World")
    try
      let server = env.args(1)?
      let port   = env.args(2)?

      env.out.print(server)
      TCPConnection(env.root as AmbientAuth, IRCChatConnectionNotify("redonapony", env), server, port)
    else
      env.err.print("Usage: ./irc_on_a_pony servername port")
    end
