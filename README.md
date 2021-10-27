# Parasite - dll injection/hijack made fun

Why dll injection/hijack has to be boring? Nim is fun and allows for combining
jester, winim and some fancy css in a single tiny library.

This project was created to learn Nim and play with some Windows internals. 
I wanted to take over running process and be able to call winapi functions 
under different security context.

## Screenshots

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
```

- `-d:fakeexports` will include fakeexports.nim and predefined `dbghelp.dll` export.

## Known Issues

- Not tested under x86 architecture
- WMI module is not ready yet

Heavily inspired by wonderful [byt3bl33d3r/OffensiveNim](https://github.com/byt3bl33d3r/OffensiveNim) repo.