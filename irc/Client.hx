package irc;

import haxe.ds.Option;
import neko.vm.Thread;
import neko.vm.Deque;

import irc.Context;
import irc.event.Received;
import irc.event.Listener;


class Client {

    public function new() { }

    static public function async_reader(ctx: Context, main: Thread): Thread {
        var reader_thead: Thread = Thread.create(Client._reader.bind(ctx));
        reader_thead.sendMessage(main);
        return reader_thead;
    }


    static private function _reader(ctx: Context): Void {
        var main: Thread = Thread.readMessage(true);
        try {
            while (true) {
                var received = ctx.irc.read();
                switch (received) {
                    case None:
                        Sys.sleep(1);
                    case Some(e):
                        Listener.notify(e, ctx);
                }
            }
        } catch(_: Dynamic) {
            ctx.irc.close();
            main.sendMessage("connection error!");
        }
    }
}


