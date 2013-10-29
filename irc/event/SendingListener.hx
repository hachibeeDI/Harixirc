package irc.event;

import irc.Context;
import irc.event.Sending;


using Lambda;


class SendingListener {
    // どうせたいした種類のイベントないしArrayでよさげ
    private static var connect(default, null): Array<Sending -> Context -> Void> = [];
    private static var join(default, null): Array<Sending -> Context -> Void> = [];
    private static var message(default, null): Array<Sending -> Context -> Void> = [];

    public function new() { }

    public static function add(e: Sending, func: Sending -> Context -> Void): Void {
        var listener = switch (e) {
            case Sending.CONNECT: connect;
            case Sending.JOIN: join;
            case Sending.MESSAGE: message;
        }
        listener.push(func);
    }

    public static function notify(e: Sending, ctx: Context): Void {
        var listener = switch (e) {
            case Sending.CONNECT: connect;
            case Sending.JOIN: join;
            case Sending.MESSAGE: message;
        }
        listener.iter(
            function(l) {
                l(e, ctx);
            }
        );
    }

}
