use "debug"
use "net"
use "buffered"

class IRCChatConnectionNotify is TCPConnectionNotify
  let _nick: String
  let _reader: Reader

  new iso create(nick: String) =>
    _nick = nick
    _reader = Reader

  fun ref connected(conn: TCPConnection ref) =>
    conn.write("NICK _nick\r\n")
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
      if line.contains("PING :") then
        _process_ping(line, conn)
      end
      Debug("> " + line)
      


    fun ref _process_ping(line: String, conn: TCPConnection ref) =>
      let len: USize = line.size()
      let subst: String val = line.substring(6, len.isize())
      conn.write("PONG " + subst + "\r\n")
      Debug("< PONG " + subst)

