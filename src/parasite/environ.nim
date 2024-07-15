import strtabs
import winim
import psapi
import os
import strutils


proc getEnvInfo*(): StringTableRef =
  ## Returns table with details regarding process/system environment.
  result = newStringTable()
  result["Current User"] = getCurrentUser()
  result["Image"] = getModulesInfo()[0].path
  result["Elevated"] = $isElevated()
  result["Process ID"] = $GetCurrentProcessId()
  result["Process Name"] = getAppFilename().rsplit('\\', 1)[1]
  result["Parasite Path"] = getMyPath()

when isMainModule:
  let environ = getEnvInfo()
  for k,v in environ.pairs:
    echo k & ": " & v