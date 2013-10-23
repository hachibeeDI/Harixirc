package ;

import irc.Client;
import irc.Connect;
import irc.Irc;

using StringTools;

class Main {
    public static function main() {
        var irc = new Irc().connect('localhost', 6667);
        irc.login("hachibee", "dogura", "localhost", "daiki");
        irc.join("test");
        while (true) {
            Client.reader(irc);
        }
    }
}
