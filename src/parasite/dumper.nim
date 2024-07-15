import winim

type
  MINIDUMP_TYPE = enum
    MiniDumpWithFullMemory = 0x00000002

proc MiniDumpWriteDump*(
  hProcess: HANDLE,
  processId: DWORD, 
  file: HANDLE, 
  dumpType: MINIDUMP_TYPE, 
  exceptionParam: PTR, 
  userStreamParam: PTR,
  callbackParam: PTR
): BOOL {.importc: "MiniDumpWriteDump", dynlib: r"C:\Windows\System32\dbghelp.dll", stdcall.}

proc dumpToFile*(targetPid: int, dumpFile: string): bool =
  result = false
  var hProc = OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, targetPid.DWORD)
  if not bool(hProc):
    raise newException(OSError, "Unable to obtain process handle.")
  try:
    var df = open(dumpFile, fmWrite)
    result = bool(MiniDumpWriteDump(
      hProc,
      targetPid.DWORD,
      df.getOsFileHandle(),
      MiniDumpWithFullMemory,
      NULL,
      NULL,
      NULL
    ))
    df.close()
  finally:
    CloseHandle(hProc)    
