package configure;

import neko.vm.Mutex;
import haxe.Json;
import sys.io.File;


class Load {
    static var FILE_PATH;

    public var m(default, null): Mutex;
    public var conf(get_conf, null): Configure;

    public function new() {
        if (FILE_PATH == null) FILE_PATH = '${Sys.getEnv("HOME")}/.config/.harixirc.json';
        this.m = new Mutex();
        this.conf = Json.parse(this.init_configure());
    }

    private function init_configure(): String {
        var f = File.getContent(FILE_PATH);
        trace(f);
        return f;
        // return f.readAll().toString();
    }

    public function get_conf(): Configure {
        m.acquire();
        return this.conf;
        m.release();
    }
}


typedef Configure = {
    nickname: String,
    username: String,
    realname: String,
    localaddress: String,
    server: Map<String, {server: String, port: Int}>
}
