import winim
import strutils
import strformat
import psutil / psutil_windows

type Module* = object
  name*, path*: string
  handle*: int
  hasNimMain*: bool

type ModuleList* = seq[Module]

type Process* = object
  pid*: int
  name*, path*: string
  accessible*: bool

type ProcessList* = seq[Process]

func `$`*(self: ModuleList): string =
  result.add("Modules list:" & '\n')
  for m in self:
    result.add(fmt"  * 0x{m.handle:x} {m.path} NimMain:{m.hasNimMain}" & '\n')

func `$`*(self: ProcessList): string =
  result.add("Running processes:" & '\n')
  for p in self:
    result.add(fmt"[{p.pid}] {p.name} ({p.path}) ACCESS:{p.accessible}" & '\n')

func `$`*(self: var seq[char]): string {.inline.} =
  ## Convinient function to convert null terminated cstring in form of `seq[char]`
  ## to native string type and get rid of remaining \0s. 
  self.setLen(self.find('\0'))
  result = self.join

proc resolveModule(hProcess: HANDLE, hMod: HMODULE): string =
  ## Resolve the DLL name.
  var modName = newSeq[char](MAX_PATH)
  GetModuleFileNameExA(hProcess, hMod, addr modName[0], MAX_PATH.DWORD)
  result = $modName

proc loadModule*(modName: string): bool =
  ## Load DLL using `LoadLibraryA` function.
  let hMod = LoadLibraryA(modName.LPCSTR)
  return hMod != 0

proc unloadModule*(modName: string): bool =
  ## Call `FreeLibrary` to unload DLL.
  let hMod = GetModuleHandleA(modName.LPCSTR)
  if hMod == 0:
    return false
  return FreeLibrary(hMod) != 0

proc getModulesInfo*(): ModuleList =
  ## Gather information regarding loaded dlls and return populated 
  ## `ModuleList` type.
  type ModuleHandles = array[1024, HMODULE]
  let
    hProcess = GetCurrentProcess()
  var  
    cbNeeded = 0.DWORD
    hMods: ModuleHandles
    moduleList: ModuleList
  if EnumProcessModules(hProcess, &hMods[0], sizeof(hMods).DWORD, &cbNeeded) == FALSE:
    raise newException(IOError, "Unable to enumerate process modules") 
  for h in hMods:
    if h != 0:
      let
        mPath = resolveModule(hProcess, h)
        mName = mPath.rsplit('\\', maxsplit=1)[1]
        hasNimMain = GetProcAddress(h, "NimMain".LPCSTR) != cast[FARPROC](0)
        mdl = Module(name: mName, path: mPath, handle: h, hasNimMain:hasNimMain)
      moduleList.add(mdl)
  result = moduleList

proc getMyPath*(): string =
  ## Determine dll path on disk. 
  for m in getModulesInfo().items:
    if m.hasNimMain:
      return m.path
  return getModulesInfo()[0].path  # quick fix for parasrv

proc getCurrentUser*(): string =
  ## Call `GetUserNameA` to obtain name of the owner of current process.
  var userBuf = newSeq[char](MAXPATH)
  var bufLen: DWORD = MAXPATH
  if not bool(GetUserNameA(addr userBuf[0], addr bufLen)):
    raise newException(OSError, "GetUserNameA failed.")
  result = $userBuf

proc resolvePidPath*(targetPid: int): string =
  ## Returns a disk path of given PID.
  let hProc = OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, targetPid.DWORD)
  var lpFilename = newSeq[char](MAX_PATH)
  if hProc == 0:
    raise newException(OSError, "Unable to obtain process handle.")
  GetProcessImageFileNameA(hProc, addr lpFilename[0], MAX_PATH)
  result = $lpFilename
  CloseHandle(hProc)

proc getRunningProcesses*(): ProcessList =
  ## Returns a list of running processes.
  var processList: ProcessList 
  for p in pids().items:
    var 
      procName = "Unknown"
      procPath = "Unknown"
      accessible: bool = false
    try:
      procPath = resolvePidPath(p)    
      if '\\' in procPath:
        procName = procPath.rsplit('\\', maxsplit=1)[1]
        accessible = true
    except OSError:
      discard
    let process = Process(name: procName, path: procPath, pid: p, accessible:accessible)
    processList.add(process)
  return processList

proc terminatePid*(targetPid: int) =
  ## Terminate remote process of given `targetPid`
  let hProc = OpenProcess(PROCESS_TERMINATE, FALSE, targetPid.DWORD)
  if hProc == 0:
    raise newException(OSError, "Unable to obtain process handle.")
  if TerminateProcess(hProc, 0.UINT) == 0:
    raise newException(OSError, "Unable to terminate process.")
  CloseHandle(hProc)

proc terminateThread*() =
  ## Terminate current thread
  ExitThread(0)

proc isElevated*(): bool =
  ## Determine if current process is assigned with elevated token.
  let
    tokenElevation = cast[TOKEN_INFORMATION_CLASS](20)
  var
    hToken: HANDLE
    elevation: TOKEN_ELEVATION
    cbSize = sizeof(elevation).DWORD
  if not bool(OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken)):
    raise newException(OSError, "Unable to obtain process token.")
  if not bool(GetTokenInformation(hToken, tokenElevation, &elevation, sizeof(elevation).DWORD, &cbSize)):
    raise newException(OSError, "Unable to obtain process token information.")
  CloseHandle(hToken)
  return bool(elevation.TokenIsElevated)

when isMainModule:
  echo "Process elevated: " & $isElevated()
  echo $getModulesInfo()
  # echo $getRunningProcesses()
