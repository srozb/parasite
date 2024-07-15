import winim/com

proc queryWmi*(namespace, query: string): string =  #  WIP: BROKEN
  let wmi = GetObject(r"winmgmts:{impersonationLevel=impersonate}!\\.\" & namespace)
  for i in wmi.execQuery(query):
    result.add($i.handle & ":" & $i.name & '\n')

when isMainModule:
  # discard queryWmi(r"root\securitycenter2", "SELECT displayName FROM AntiVirusProduct")
  echo queryWmi(r"root\cimv2", "select * from win32_process")