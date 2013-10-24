package ;

import neko.vm.Thread;
import haxe.io.Input;

import irc.Client;
import irc.Connect;
import irc.Irc;

using StringTools;

class Main {
    static inline var CHAN = "test";
    static inline var SERVER = "10.30.138.100";
    static inline var PORT = 6667;


    public static function main() {
        var irc = new Irc().connect(SERVER, PORT);
        irc.login("hachitest", "doguratest", "test.com", "daiki");
        irc.join(CHAN);
        var reader_thead =
            Thread.create(
                function() {
                    try {
                        while (true) {
                            switch (Client.reader(irc)) {
                                case None: return;
                                case Some(msg): trace(msg);
                            }
                        }
                    } catch(_: Dynamic) {
                        irc.close();
                    }
                }
            );
        // user input
        var input = Sys.stdin();
        // TODO: この部分も後で抽象化
        while (true) {
            var m = input.readLine();
            if (m.trim() == "") break;
            irc.talk(m, CHAN);
        }
        Thread.readMessage(true);
    }
}
