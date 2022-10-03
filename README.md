# Parasite - dll injection/hijack made fun

Why dll injection/hijack has to be boring? This project aims to create fun dll 
library that brings some neat features to pwned process. It combines the power 
of jester, winim as well as bulma css and htmx to keep your experience on 
desired level. All compiled into single binary under 1MB size.

I've created it to learn Nim and get familiar with Windows internals, especially
wanted to play around with some winapi functions under different security 
context.

It's also suitable for pwning Microsoft Office by planting malicious Add-ons 
(XLL etc.).

## Showcase

![Frontpage](imgs/front.PNG)

![Processes](imgs/processes.PNG)

## Features

- Run on DLL load (`DllMain`) with optional fake exports, if loader expects them
- Http server listening on loopback interface, running within injected context (e.g. `lsass.exe`)
- Load/unload dlls in running process
- Dump remote process memory to disk (using `dbghelp.dll` `MiniDumpWriteDump`)
- Migrate to other process by a classic dll injection (`WriteProcessMemory` & `CreateRemoteThread` to `LoadLibrary`)
- Execute shell command in the context of injected process
- Modular, easy to extend design - modules can be compiled to standalone execs (injector, dumper)
- It's fast!

## Requirements

Tested under Windows 10 64-bit with the following dependencies: 

(Nim 1.6.0)

- Winim=3.6.1
- Jester=0.5.0
- Nimja=0.4.0
- psutil=0.6.1 (https://github.com/enthus1ast/psutil-nim)

## Building

64bit binaries are precompiled and ready to be downloaded. 

You can compile library and executables with `nimble build` or alternatively:

```batch
nim c --app=lib --nomain -d:dumper -d:release --passL:-s -o:parasite-x64.dll src\parasite.nim
nim c --app=lib --nomain -d:dumper -d:fakeexports -d:release --passL:-s -o:dbghelp.dll parasite.nim
```

- `-d:fakeexports` will include fakeexports.nim and predefined `dbghelp.dll` 
export. Feel free to adjust it to your needs.

### x86 support

You can use 32bit version of Nim to compile parasite to x86 arch. 
Alternatively, you can cross-compile on x64:

1. Ensure mingw-32 is in your path variable.
2. Compile with the following flags:

```
nim --cpu:i386 -d:release c src\parasite.nim
```

## Known Issues

- Loader lock present
- WMI module is not ready yet

## Acknoledgments

Heavily inspired by wonderful [byt3bl33d3r/OffensiveNim](https://github.com/byt3bl33d3r/OffensiveNim) repo.