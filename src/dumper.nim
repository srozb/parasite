import winim

type
  MINIDUMP_TYPE = enum
    MiniDumpWithFullMemory = 0x00000002

proc MiniDumpWriteDump*(
  hProcess: HANDLE,
  ProcessId: DWORD, 
  hFile: HANDLE, 
  DumpType: MINIDUMP_TYPE, 
  ExceptionParam: PTR, 
  UserStreamParam: PTR,
  CallbackParam: PTR
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

when isMainModule:
  import os
  import strutils
  if paramCount() != 2:
    echo "usage: dumper <pid> <dump filename>"
    quit(-1)
  var res = dumpToFile(paramStr(1).parseInt(), paramStr(2))
  echo "All done. Success:" & $res
