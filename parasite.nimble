# Package

version       = "0.3.2"
author        = "srozb"
description   = "dll injection/hijack made fun"
license       = "MIT"
srcDir        = "src"
binDir        = "release"
# installExt    = @["nim"]
# installFiles   = @["parasite.nim"]
namedBin = {
    "parasite"  : "parasite.dll", 
    "injector"  : "injector.exe", 
    "httpserv"  : "para_http.exe",
    "dumper"    : "para_dump.exe"
}.toTable()


# Dependencies

requires "nim >= 2.0.0, winim, jester, nimja, https://github.com/enthus1ast/psutil-nim"
