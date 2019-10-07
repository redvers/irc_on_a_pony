use "debug"
use "net"

actor Main
  new create(env: Env) =>
    env.out.print("Hello World")
    try
      TCPConnection(env.root as AmbientAuth, IRCChatConnectionNotify("redonapony"), "irc.fussake.com", "6667")
    else
      Debug("Ouch")
    end
