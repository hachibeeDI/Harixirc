package irc;

import haxe.ds.Option;

using StringTools;


class Irc {
    private var conn(default, null): Connect;

    public function new() { }
    public function connect(address, port): Irc {
        this.conn = new Connect(address, port);
        return this;
    }

    public function read(): Option<String> {
        var msg = Std.string(this.conn.receive()).trim();
        if (msg == "") {
            return Option.None;
        }
        else {
            return Option.Some(msg);
        }
    }

    public function login(nickname, username, servername, realname): Void {
        var msg = 'USER ${username} localhost ${servername} ${realname}';
        this.conn.send(msg);
        this.conn.send('NICK ${nickname}');
    }

    public function join(channel): Void {
        this.conn.send('JOIN #${channel}');
    }

    public function ping(): Void {
        // TODO: 途中
        this.conn.send('PING ');
    }

    public function pong(daemon): Void {
        this.conn.send('PING ${daemon}');
    }

    public function talk(msg, channel): Void {
        this.conn.send('PRIVMSG #${channel} :${msg}');
    }
}

