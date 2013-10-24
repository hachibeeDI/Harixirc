package irc.event;

enum Received {
    PRIVMSG(targ: String, msg: String);
    PING(daemon: String);
    ANY(msg: String);
}
