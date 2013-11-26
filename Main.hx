package ;

import neko.vm.Thread;
import neko.vm.Deque;
import neko.vm.Mutex;
import haxe.io.Input;
import haxe.ds.Option;

import irc.Client;
import irc.Connect;
import irc.Context;
import irc.Irc;
import irc.event.Received;
import irc.event.ReceiveListener;
import irc.event.Sending;
import irc.event.SendingListener;
import configure.Load;


using StringTools;


class Main {
    static var CONF: Load;
    static inline var CHAN = "testt";
    static inline var SERVER = "10.30.138.100";
    static inline var LOCALSERVER = "localhost";
    static inline var PORT = 6667;


    public static function main() {
        CONF = new Load();

        register_default_event();
        register_default_writer();
        var th_dque = new Deque<String>();
        var irc = new Irc();
        // irc.join(CHAN);

        var ctx = new Context(irc, th_dque, CHAN);
        var main_thread = Thread.current();
        var reader_thead = Client.async_reader(ctx, main_thread);
        th_dque.add("--reading");

        // 入力待ちスレッド
        var writer_thead = Client.async_writer(ctx, new KeyInput());
        th_dque.add("--write prepare");
 
        while (true) {
            Sys.println(th_dque.pop(true));
        }

        Thread.readMessage(true);
    }

    /**
      * とりあえずの
     */
    static function register_default_event() {
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

    public static function register_default_writer() {
        SendingListener.add(
            Sending.CONNECT(null, null)
            , function(e: Sending, ctx) {
                var params = e.getParameters();
                var server = params[0];
                var port: Option<Int> = params[1];
                var conf = CONF.get_conf();
                switch (port) {
                    case Some(i): ctx.irc.connect(server, i);
                    case None:
                        trace('hoge');
                        var serv = Reflect.field(conf.server, server);
                        if (serv == null) {
                            trace('invalid servername');
                            return;
                        }
                        ctx.irc.connect(serv.server, serv.port);
                }
                ctx.irc.login(conf.nickname, conf.username, conf.localaddress, conf.realname);
            }
        );
        SendingListener.add(
            Sending.JOIN(null)
            , function(e: Sending, ctx) {
                var chan = e.getParameters()[0];
                ctx.current_channel = chan;
                ctx.irc.join(chan);
            }
        );
        SendingListener.add(
            Sending.MESSAGE(null)
            , function(e: Sending, ctx) {
                if (ctx.current_channel == null) {
                    ctx.shared_deque.push("You did not join any channel yet");
                    return ;
                }
                var msg = e.getParameters()[0];
                ctx.irc.talk(msg, ctx.current_channel);
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
