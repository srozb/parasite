import winim
import strutils

const
  COOKIE_TYPE = 0
  TID_OFFSET = (sizeof(uint) - sizeof(WORD))*8
  TID_MASK = 0x0fff

proc LdrLockLoaderLock(flags: ULONG, disposition: PULONG, cookie: PVOID): NTSTATUS {.winapi, stdcall, dynlib: "ntdll", importc.}
proc LdrUnlockLoaderLock(flags: ULONG, cookie: PVOID): NTSTATUS {.winapi, stdcall, dynlib: "ntdll", importc.}

proc genLockCookie(cookieType = COOKIE_TYPE, lockCount:DWORD = 1): uint =
  ## Generate cookie value. COOKIE_TYPE other than 0 not supported.
  return ((GetCurrentThreadId() and TID_MASK).uint shl TID_OFFSET) or 0x1

proc unlockLoaderLock*() =
  let 
    cookie = genLockCookie()
    res = LdrUnlockLoaderLock(0.ULONG, cast[PVOID](cookie))

  if res == 0: discard "LoaderLock unlocked!"
  else: 
    if res == 0xC00000F0: discard "Invalid Cookie value."
    quit()

proc lockLoaderLock*() =
  var 
    disp: PULONG
    newCookie: uint
    res = LdrLockLoaderLock(0.ULONG, disp, addr newCookie)
  if res == 0: 
    discard "LoaderLock locked, obtained cookie: 0x" & newCookie.toHex
  else: discard "Failed with: 0x" & res.toHex

template withLoaderUnlocked*(body: untyped) = 
  unlockLoaderLock()
  body
  lockLoaderLock()