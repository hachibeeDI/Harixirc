package irc;

class Client {

    public function new() { }
    static public function reader(irc: Irc) {
        var msg = irc.read();
        switch (msg) {
            case None:
                Sys.sleep(2);
            case Some(m):
                var msgs = m.split(" ");
                switch (msgs) {
                    case [type, daemon] if (type == "PING"):
                        trace("イヤーーッ！");
                        irc.pong(daemon);
                    case _:
                        trace(msgs);
                }
        }
    }
}
