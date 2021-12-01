import winim

proc archMatch(hProcess: HANDLE): bool =
  ## Returns true if DLL architecture matches target process architecture.
  var
    isInjector64bit: BOOL
    isTarget64bit: BOOL
  discard IsWow64Process(GetCurrentProcess(), addr isInjector64bit)
  discard IsWow64Process(hProcess, addr isTarget64bit)
  return (isInjector64bit == isTarget64bit).bool

proc processWrite*(hProcess: HANDLE, buffer: string, protect: DWORD): LPVOID =
  ## Allocate memory and write string buffer within. Returns pointer to 
  ## allocated memory address.
  let 
    buf = winstrConverterStringToPtrChar(buffer & '\0')
    bufSize = (len(buffer) + 1).SIZE_T
  result = VirtualAllocEx(hProcess, NULL, bufSize, MEM_COMMIT or MEM_RESERVE, protect)
  if WriteProcessMemory(hProcess, result, buf, bufSize, NULL) == 0:
    raise newException(OSError, "WriteProcessMemory error: " & $GetLastError())

proc resolveFunc(modName, funcName: string): FARPROC =
  ## Returns pointer to given procedure.
  var hModule = GetModuleHandleA(modName.LPCSTR)
  result = GetProcAddress(hModule, funcName.LPCSTR)
  CloseHandle(hModule)

proc injectModule*(pid: int, modName: string) =
  ## Inject DLL into foreign process. `modName` can be filename or absolute path.
  let 
    hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid.DWORD)
    addrLoadLibraryA = resolveFunc("kernel32.dll", "LoadLibraryA")
    pathAddr = processWrite(hProcess, modName, PAGE_READWRITE)
  if not archMatch(hProcess):
    raise newException(OSError, "Incompatible architecture (between injector and target process).")
  let hRemoteThread = CreateRemoteThread(
      hProcess, 
      cast[LPSECURITY_ATTRIBUTES](NULL), 
      0.SIZE_T, 
      cast[LPTHREAD_START_ROUTINE](addrLoadLibraryA), 
      pathAddr, 
      cast[DWORD](NULL), 
      cast[LPDWORD](NULL)
    )
  if hRemoteThread != 0.HANDLE:
    discard WaitForSingleObject(hRemoteThread, 10000.DWORD)
  VirtualFreeEx(hProcess, pathAddr, 0, MEM_RELEASE)
  CloseHandle(hProcess)
  CloseHandle(hRemoteThread)

when isMainModule:
  import os
  import strutils
  if paramCount() != 2:
    echo "usage: injector <pid> <dll>"
    quit(-1)
  injectModule(paramStr(1).parseInt(), paramStr(2))
  echo "All done."
  