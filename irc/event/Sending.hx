package irc.event;

enum Sending {
    CONNECT(server: String, port: Int);
    JOIN(chan: String);
    MESSAGE(msg: String);  // 実質デフォルトになる
}

