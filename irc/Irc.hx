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

    private function send(msg): Void {
        this.conn.send(msg);
        return ;
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
        this.send(msg);
        this.send('NICK ${nickname}');
    }

    public function join(channel): Void {
        this.send('JOIN #${channel}');
    }

    public function ping(): Void {
        // TODO: 途中
        this.send('PING ');
    }

    public function pong(daemon): Void {
        this.send('PING ${daemon}');
    }

    public function talk(msg, channel): Void {
        this.send('PRIVMSG #${channel} :${msg}');
    }

    public function close():Void {
        this.conn.close();
    }
}

