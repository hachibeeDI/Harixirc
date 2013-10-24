package irc;

import sys.net.Socket;
import haxe.remoting.AsyncConnection;
import sys.net.Host;


class Connect {
    static inline var END_OF_MSG = "\r\n";

    public var conn(default, null): Socket;

    public function new(address, port) {
        this.conn = new Socket();
        this.conn.connect(new Host(address), port);
    }

    public function send(msg: String): Void {
        this.conn.output.writeString('${msg}${END_OF_MSG}');
        // this.conn.write('${msg}${END_OF_MSG}');
    }

    public function receive(): String {
        return this.conn.input.readLine();
    }

    public function close(): Void {
        this.conn.close();
    }

}
