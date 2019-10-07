use "debug"
use "net"
use "buffered"

class IRCChatConnectionNotify is TCPConnectionNotify
  let _nick: String
  let _env: Env
  let _reader: Reader

  new iso create(nick: String, env: Env) =>
    _nick = nick
    _env = env
    _reader = Reader

  fun ref connected(conn: TCPConnection ref) =>
    Debug("< NICK " + _nick)
    conn.write("NICK " + _nick + "\r\n")
    Debug("< USER red 0 * :red")
    conn.write("USER red 0 * :red\r\n")
    _env.out.print("Logging in as user " + _nick)

  fun ref connect_failed(conn: TCPConnection ref) =>
    Debug("Connection Failed")
    _env.err.print("Connection failed")
    None

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize) : Bool
  =>
    _reader.append(consume data) // Reader.append requires a val

    /*
      This feels so wrong.  The loop processes each line until the _reader.line()?
    fails out and the try block fails.  My brain says I should be making the while
    clause be "is there a line available in the buffer" instead of always true.
    */
    try
      while true do
        let line: String = _reader.line()?
        _process_message(line, conn)
      end
    end

    // The fuction signature shows we must return a Bool.
    true


    fun ref _process_message(line: String, conn: TCPConnection ref) =>
      // In the IRC protocol, the PING message doesn't match the other formats.
      if (line.substring(0,5) == "PING ") then
        _process_ping(line, conn)
      end

      /* 
        Messages from the server in general look like this:
        :prefix command (any number of args)\r\n
      */
      try
        match line.split().apply(1)?
        | "376"     => _joinchannel(line, conn)
        | "PRIVMSG" => _message_received(line, conn)
        else
          Debug("> " + line)
        end
      end

    fun ref _joinchannel(line: String, conn: TCPConnection ref) =>
      Debug("< JOIN #norrath")
      _env.out.print("JOINing channel #norrath")
      conn.write("JOIN #norrath\r\n")
      
    fun ref _message_received(line: String, conn: TCPConnection ref) =>
      try
        let message: Array[String val] = line.split(" ")
        let from: String val = message.shift()?
        message.shift()?

        var buff = from + " >>> "

        for a in message.values() do
          buff = buff + " " + a
        end

        _env.out.print(buff)
      end
      
      


    fun ref _process_ping(line: String, conn: TCPConnection ref) =>
      let len: USize = line.size()
      let subst: String val = line.substring(6, len.isize())
      conn.write("PONG " + subst + "\r\n")
      Debug("< PONG " + subst)

