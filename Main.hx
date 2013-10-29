package ;

import neko.vm.Thread;
import neko.vm.Deque;
import neko.vm.Mutex;
import haxe.io.Input;

import irc.Client;
import irc.Connect;
import irc.Context;
import irc.Irc;
import irc.event.Received;
import irc.event.ReceiveListener;

import growl.Growl;


using StringTools;

class Main {
    static inline var CHAN = "testt";
    static inline var SERVER = "10.30.138.100";
    static inline var LOCALSERVER = "localhost";
    static inline var PORT = 6667;


    public static function main() {
        register_default_event();
        var th_dque = new Deque<String>();
        var irc = new Irc().connect(SERVER, PORT);
        irc.login("hachi", "doguratest", "test.com", "daiki");
        irc.join(CHAN);

        var ctx = new Context(irc, th_dque);
        var reader_thead = Client.async_reader(ctx, Thread.current());
        // reader_thead.sendMessage(Thread.current());
        // reader_thead.sendMessage(th_dque);
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

    /**
      * とりあえずの
     */
    static function register_default_event() {
        ReceiveListener.prepare();
        ReceiveListener.add(
            Received.PING('')
            , function(e: Received, ctx: Context) {
                var daemon = e.getParameters()[0]; // ダサすぎ・・・
                ctx.irc.pong(daemon);
            }
        );
        ReceiveListener.add(
            Received.PRIVMSG(null, null)
            , function(e: Received, ctx) {
                var targ = e.getParameters()[0]; // はやくなんとかしないと
                var msg = e.getParameters()[1];
                ctx.shared_deque.add(msg);
            }
        );
        ReceiveListener.add(
            Received.ANY(null)
            , function(e: Received, ctx) {
                var msg = e.getParameters()[0];
                ctx.shared_deque.add(msg);
            }
        );
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
