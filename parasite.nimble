# Package

version       = "0.2.0"
author        = "srozb"
description   = "dll injection/hijack made fun"
license       = "MIT"
srcDir        = "src"
# installExt    = @["nim"]
installFiles   = @["parasite.nim"]
namedBin = {
    "parasite"  : "parasite.dll", 
    "injector"  : "injector.exe", 
    "httpserv"  : "para_http.exe",
    "dumper"    : "para_dump.exe"
}.toTable()


# Dependencies

requires "nim >= 1.6.0, winim, jester, nimja, https://github.com/enthus1ast/psutil-nim"
