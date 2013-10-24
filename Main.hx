package ;

import neko.vm.Thread;
import neko.vm.Deque;
import neko.vm.Mutex;
import haxe.io.Input;

import irc.Client;
import irc.Connect;
import irc.Irc;

using StringTools;

class Main {
    static inline var CHAN = "testt";
    static inline var SERVER = "10.30.138.100";
    static inline var PORT = 6667;


    public static function main() {
        var th_dque = new Deque<String>();
        var irc = new Irc().connect(SERVER, PORT);
        irc.login("hachitest", "doguratest", "test.com", "daiki");
        irc.join(CHAN);
        var reader_thead = Thread.create(reader.bind(irc));
        reader_thead.sendMessage(Thread.current());
        reader_thead.sendMessage(th_dque);
        th_dque.add("--reading");

        // 入力待ちスレッド
        var writer_thead = Thread.create(writer.bind(irc));
        writer_thead.sendMessage(th_dque);
        writer_thead.sendMessage(new KeyInput());
        th_dque.add("--write prepare");
 
        while (true) {
            Sys.println(th_dque.pop(true));
        }

        Thread.readMessage(true);
    }

    static function reader(irc: Irc) {
        var main: Thread = Thread.readMessage(true);
        var deque: Deque<String> = Thread.readMessage(true);
        try {
            while (true) {
                switch (Client.reader(irc)) {
                    case None: return;
                    case Some(msg): deque.add(msg);
                }
            }
        } catch(_: Dynamic) {
            irc.close();
            main.sendMessage("connection error!");
        }
    }

    static function writer(irc: Irc) {
        var deque: Deque<String> = Thread.readMessage(true);
        var input: KeyInput = Thread.readMessage(true);
        // TODO: この部分も後で抽象化
        while (true) {
            var m = input.readLine();
            if (m == null) continue;
            var msg = m.trim();
            if (msg == "") continue;
            irc.talk(msg, CHAN);
        }
        deque.add('---write error');
    }
}


class KeyInput {
    public var m(default, null): Mutex;
    public var input(default, null): Input;

    public function new() {
        this.m = new Mutex();
        this.input = Sys.stdin();
    }

    public function readLine(): String {
        m.acquire();
        var val = this.input.readLine();
        m.release();
        return val;
    }
}
