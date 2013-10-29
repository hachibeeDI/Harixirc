package irc.event;

import irc.Context;
import irc.event.Received;

using Lambda;


class ReceiveListener {
    // static inline var listeners: Array<irc.Irc -> Void> = [];
    private static var priv_msg(default, null): Array<Received -> Context -> Void>;
    private static var ping(default, null): Array<Received -> Context -> Void>;
    private static var any(default, null): Array<Received -> Context -> Void>;

    private function new() { }

    public static function prepare() {
        priv_msg = [];
        ping = [];
        any = [];
    }

    public static function add(e: Received, func: Received -> Context -> Void): Void {
        var listener = switch (e) {
            case Received.PRIVMSG: priv_msg;
            case Received.PING: ping;
            case Received.ANY: any;
        }
        listener.push(func);
    }

    public static function notify(e: Received, ctx: Context) {
        var listener = switch (e) {
            case Received.PRIVMSG: priv_msg;
            case Received.PING: ping;
            case Received.ANY: any;
        }
        listener.iter(
            function(l) {
               l(e, ctx);
            }
        );
    }
}
