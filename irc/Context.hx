package irc;

import neko.vm.Deque;

import irc.Irc;


class Context {
    public var irc(default, null): Irc;
    public var shared_deque(default, null): Deque<String>;

    public function new(irc: Irc, shared_deque: Deque<String>) {
        this.irc = irc;
        this.shared_deque = shared_deque;
    }
}


