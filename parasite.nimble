# Package

version       = "0.4.3"
author        = "srozb"
description   = "dll injection/hijack made fun"
license       = "MIT"
srcDir        = "src"
binDir        = "release"

namedBin = {
    "parasite"  : "parasite.dll", 
    "injector"  : "injector.exe", 
    "parahttp"  : "parahttp.exe",
    "parasrv"   : "parasrv.exe",
    "dumper"    : "dumper.exe"
}.toTable()

requires "nim >= 2.0.0, winim == 3.9.3, jester == 0.6.0, nimja == 0.8.7, https://github.com/enthus1ast/psutil-nim"
