import strtabs
import winim
import psapi
import os
import strutils


proc getVer(): string {.compileTime.} =
  ## Returns parasite version string.
  let nimble = staticRead("../parasite.nimble")
  for l in nimble.splitLines():
    if l.strip().startsWith("version"):
      return l.split('"')[1]
  return "<unknown>"

proc getCompileEnv(): string {.compileTime.} =
  ## Returns compilation details for easier tracking.
  let user = staticExec("whoami").strip()
  let host = staticExec("hostname").strip()
  return user & "@" & host

const 
  arch* = $(sizeof(int)*8)
  ver* = getVer()
  compiled* = getCompileEnv()

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