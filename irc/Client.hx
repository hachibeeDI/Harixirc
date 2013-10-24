package irc;

import haxe.ds.Option;


class Client {

    public function new() { }
    // TODO: Eitherの方がよい？
    static public function reader(irc: Irc): Option<String> {
        var msg = irc.read();
        switch (msg) {
            case None:
                Sys.sleep(2);  // TODO: この秒数は設定でいじれるようにしておこう
                return None;
            case Some(m):
                var msgs = m.split(" ");
                switch (msgs) {
                    case [type, daemon] if (type == "PING"):
                        irc.pong(daemon);
                        return None;
                    case _:
                        return Option.Some(m);
                }
        }
    }
}
