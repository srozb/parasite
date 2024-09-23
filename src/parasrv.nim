import winim
import std/os
import parasite/httpserv

const
  SERVICE_NAME = "parasrv"
  SLEEP_INTERVAL = 60_000

var
  ServiceStatus: SERVICE_STATUS
  hStatus: SERVICE_STATUS_HANDLE

proc runThreadedHttpServ() =
  let hThread = CreateThread(
    cast[LPSECURITY_ATTRIBUTES](NULL),
    0.SIZE_T,
    cast[LPTHREAD_START_ROUTINE](runHttpServ),
    cast[LPVOID](NULL),
    0.DWORD,
    cast[LPDWORD](NULL),
  )
  if hThread == 0:
    return
  WaitForSingleObject(hThread, 20000.DWORD)

proc initService(): int =
  runThreadedHttpServ()
  return 0

proc ControlHandler(request: DWORD) {.stdcall.} =
  case request
  of SERVICE_CONTROL_STOP or SERVICE_CONTROL_SHUTDOWN: # TODO: kill httpsrv thread
    ServiceStatus.dwWin32ExitCode = 0
    ServiceStatus.dwCurrentState = SERVICE_STOPPED
    SetServiceStatus(hStatus, addr ServiceStatus)
  else:
    discard

proc ServiceMain() {.stdcall.} =
  var hStatus =
    RegisterServiceCtrlHandler(SERVICE_NAME, cast[LPHANDLER_FUNCTION](ControlHandler))

  if hStatus == cast[SERVICE_STATUS_HANDLE](0):
    return

  ServiceStatus.dwServiceType = SERVICE_WIN32
  ServiceStatus.dwCurrentState = SERVICE_START_PENDING
  ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN
  ServiceStatus.dwWin32ExitCode = 0
  ServiceStatus.dwServiceSpecificExitCode = 0
  ServiceStatus.dwCheckPoint = 0
  ServiceStatus.dwWaitHint = 0

  if initService() != 0:
    ServiceStatus.dwCurrentState = SERVICE_STOPPED
    ServiceStatus.dwWin32ExitCode = -1
    SetServiceStatus(hStatus, addr ServiceStatus)
    return

  ServiceStatus.dwCurrentState = SERVICE_RUNNING
  SetServiceStatus(hStatus, addr ServiceStatus)

  while ServiceStatus.dwCurrentState == SERVICE_RUNNING:
    os.sleep(SLEEP_INTERVAL)

proc main() =
  var myService: SERVICE_TABLE_ENTRYW
  myService.lpServiceName = SERVICE_NAME
  myService.lpServiceProc = cast[LPSERVICE_MAIN_FUNCTION](ServiceMain)
  StartServiceCtrlDispatcher(addr myService)

main()
