package irc;

import haxe.ds.Option;
import neko.vm.Thread;
import neko.vm.Deque;

import irc.Context;
import irc.event.Received;
import irc.event.ReceiveListener;
import irc.event.Sending;
import irc.event.SendingListener;

using StringTools;


typedef WriterObj = {
    function readLine(): String;
}


class Client {

    public function new() { }

    public static function async_reader(ctx: Context, main: Thread): Thread {
        var reader_thead: Thread = Thread.create(Client._reader.bind(ctx));
        reader_thead.sendMessage(main);
        return reader_thead;
    }

    private static function _reader(ctx: Context): Void {
        var main: Thread = Thread.readMessage(true);
        while (!ctx.irc.is_connected()) {Sys.sleep(1);}
        try {
            while (true) {
                var received = ctx.irc.read();
                switch (received) {
                    case None:
                        Sys.sleep(1);
                    case Some(e):
                        ReceiveListener.notify(e, ctx);
                }
            }
        } catch(_: Dynamic) {
            ctx.irc.close();
            main.sendMessage("connection error!");
        }
    }

    public static function async_writer(ctx: Context, input: WriterObj): Thread {
        var writer_thead: Thread = Thread.create(Client._writer.bind(ctx));
        writer_thead.sendMessage(input);
        return writer_thead;
    }

    private static function _writer(ctx: Context) {
        var input = Thread.readMessage(true);
        while (true) {
            var m: String = input.readLine();
            if (m == null) continue;
            var msg: String = m.trim();
            if (msg == "") continue;
            var event =
                switch (msg.split(" ")) {
                case ["/join", chan]:
                    Sending.JOIN(chan);
                case ["/connect", server, port]:
                    Sending.CONNECT(server, Std.parseInt(port));
                case _:
                    Sending.MESSAGE(msg);
            }
            SendingListener.notify(event, ctx);
        }
        ctx.shared_deque.add('---write error');
    }
}


