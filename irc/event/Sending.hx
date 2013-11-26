package irc.event;

import haxe.ds.Option;


enum Sending {
    CONNECT(server: String, port: Option<Int>);
    JOIN(chan: String);
    MESSAGE(msg: String);  // 実質デフォルトになる
}

