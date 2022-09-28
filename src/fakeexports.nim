## This module implements exported procedures to be present in the compiled DLL
## to prevent error upon DLL load. Below is an example of `MiniDumpWriteDump` 
## export that might be needed when parasite pretends to be `dbghelp.dll`.

import winim

{.used.}

# dbghelp.dll
# proc MiniDumpWriteDump*(
#   hProcess: HANDLE,
#   ProcessId: DWORD, 
#   hFile: HANDLE, 
#   DumpType: MINIDUMP_TYPE, 
#   ExceptionParam: INT, 
#   UserStreamParam: INT,
#   CallbackParam: INT
# ): BOOL {.stdcall, exportc, dynlib.} =
#   ## Just pretend to be `dbghelp.dll:MiniDumpWriteDump` but do nothing.
#   return true

# Excel XLL Autostart
# proc xlAutoOpen*(): int {.stdcall, exportc, dynlib.} =
#   return 1

proc DwmIsCompositionEnabled*(pfEnabled: BOOL): HRESULT {.stdcall, exportc, dynlib.} = 
  return cast[HRESULT](0)

proc DwmExtendFrameIntoClientArea*(hWnd: HWND, pMarInset: MARGINS): HRESULT {.stdcall, exportc, dynlib.} = 
  return cast[HRESULT](0)

proc DwmSetWindowAttribute*(hwnd: HWND, dwAttribute: DWORD, pvAttribute: LPCVOID, cbAttribute: DWORD): HRESULT {.stdcall, exportc, dynlib.} = 
  return cast[HRESULT](0)