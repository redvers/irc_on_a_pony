use "debug"
use "net"
use "buffered"

class IRCChatConnectionNotify is TCPConnectionNotify
  let _nick: String
  let _reader: Reader
  let _env: Env

  new iso create(nick: String, env: Env) =>
    _nick = nick
    _reader = Reader
    _env = env

  fun ref connected(conn: TCPConnection ref) =>
    Debug("< NICK " + _nick)
    conn.write("NICK " + _nick + "\r\n")
    Debug("< USER red 0 * :red")
    conn.write("USER red 0 * :red\r\n")

  fun ref connect_failed(conn: TCPConnection ref) =>
    Debug("Connection Failed")
    None

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize) : Bool
  =>
    Debug("Receieved data")

    let data': Array[U8] val = consume data


    _reader.append(data')

    try
      while true do
        let line: String = _reader.line()?
        _process_message(line, conn)
      end
    end

    true

    fun ref _process_message(line: String, conn: TCPConnection ref) =>
      if (line.substring(0,5) == "PING ") then
        _process_ping(line, conn)
      end
      //:irc.fussake.com 376 redonapony :End of message of the day.

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
      conn.write("JOIN #norrath\r\n")
      
    fun ref _message_received(line: String, conn: TCPConnection ref) =>
      try
      let message: Array[String val] = line.split(" ")
        message.shift()?
        message.shift()?

      var buff = ""

      for a in message.values() do
        buff = buff + " " + a
      end

      Debug(buff)



      end
      
      


    fun ref _process_ping(line: String, conn: TCPConnection ref) =>
      let len: USize = line.size()
      let subst: String val = line.substring(6, len.isize())
      conn.write("PONG " + subst + "\r\n")
      Debug("< PONG " + subst)

