use "debug"
use "net"

actor Main
  new create(env: Env) =>
    env.out.print("Hello World")
    try
      let server = env.args(1)?
      let port   = env.args(2)?
      env.out.print(server)
      TCPConnection(env.root as AmbientAuth, IRCChatConnectionNotify("redonapony"), server, port)
    else
      env.err.print("I was unable to make a connection...")
    end
