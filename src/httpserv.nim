when isMainModule:
  import parasite/httpserv
  proc NimMain*() {.cdecl, importc, exportc, dynlib, used.}  # psapi getMyPath() requires it

  runHttpServ()
