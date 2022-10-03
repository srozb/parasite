import winim
import httpserv
when defined(fakeexports):
  import fakeexports

proc NimMain() {.cdecl, importc.}

proc DllMain(hinstDLL: HINSTANCE, fdwReason: DWORD, lpvReserved: LPVOID): BOOL {.stdcall, exportc, dynlib.} =
  if fdwReason != DLL_PROCESS_ATTACH: return true

  NimMain()
  runHttpServ()  # beware the loader lock

  return true
