import strtabs
import winim
import psapi
import os
import strutils

const arch* = $(sizeof(int)*8)

proc getEnvInfo*(): StringTableRef =
  ## Returns table with details regarding process/system environment.
  result = newStringTable()
  result["Current User"] = getCurrentUser()
  result["Image"] = getModulesInfo()[0].path
  result["Elevated"] = $isElevated()
  result["pid"] = $GetCurrentProcessId()
  result["pName"] = getAppFilename().rsplit('\\', 1)[1]
  result["myPath"] = getMyPath()
  

when isMainModule:
  let environ = getEnvInfo()
  for k,v in environ.pairs:
    echo k & ": " & v