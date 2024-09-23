import winim
import std/os
import parasite/httpserv

const
  SERVICE_NAME = "parasrv"
  SLEEP_INTERVAL = 2_000

var
  serviceStatus: SERVICE_STATUS
  hStatus: SERVICE_STATUS_HANDLE
  httpThread: HANDLE

proc runThreadedHttpServ() =
  httpThread = CreateThread(
    cast[LPSECURITY_ATTRIBUTES](NULL),
    0.SIZE_T,
    cast[LPTHREAD_START_ROUTINE](runHttpServ),
    cast[LPVOID](NULL),
    0.DWORD,
    cast[LPDWORD](NULL),
  )
  if httpThread == 0:
    return
  discard WaitForSingleObject(httpThread, 20_000.DWORD)

proc initService(): int =
  runThreadedHttpServ()
  return 0

proc ControlHandler(request: DWORD) {.stdcall.} =
  case request
  of SERVICE_CONTROL_STOP or SERVICE_CONTROL_SHUTDOWN:
    serviceStatus.dwWin32ExitCode = 0
    serviceStatus.dwCurrentState = SERVICE_STOPPED
    discard SetserviceStatus(hStatus, addr serviceStatus)
  else:
    discard

proc ServiceMain() {.stdcall.} =
  var hStatus =
    RegisterServiceCtrlHandler(SERVICE_NAME, cast[LPHANDLER_FUNCTION](ControlHandler))

  if hStatus == cast[SERVICE_STATUS_HANDLE](0):
    return

  serviceStatus.dwServiceType = SERVICE_WIN32
  serviceStatus.dwCurrentState = SERVICE_START_PENDING
  serviceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN

  if initService() != 0:
    serviceStatus.dwCurrentState = SERVICE_STOPPED
    serviceStatus.dwWin32ExitCode = -1
    SetserviceStatus(hStatus, addr serviceStatus)
    return

  serviceStatus.dwCurrentState = SERVICE_RUNNING
  discard SetserviceStatus(hStatus, addr serviceStatus)

  while serviceStatus.dwCurrentState == SERVICE_RUNNING:
    os.sleep(SLEEP_INTERVAL)

  var hProc = GetCurrentProcess()  # Service shutdown is broken
  discard TerminateThread(httpThread, 0.DWORD)
  discard TerminateProcess(hProc, 0.UINT)

proc main() =
  var myService: SERVICE_TABLE_ENTRYW
  myService.lpServiceName = SERVICE_NAME
  myService.lpServiceProc = cast[LPSERVICE_MAIN_FUNCTION](ServiceMain)
  discard StartServiceCtrlDispatcher(addr myService)

main()
