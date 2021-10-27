import strtabs
import winim
import psapi

const arch* = $(sizeof(int)*8)

proc getEnvInfo*(): StringTableRef =
  ## Returns table with details regarding process/system environment.
  result = newStringTable()
  result["Current User"] = getCurrentUser()
  result["Image"] = getModulesInfo()[0].path
  result["PID"] = $GetCurrentProcessId()
  result["Elevated"] = $isElevated()
  

when isMainModule:
  let environ = getEnvInfo()
  for k,v in environ.pairs:
    echo k & ": " & v