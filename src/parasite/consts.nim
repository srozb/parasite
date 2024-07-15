import strutils
import std/[paths, macros]
import utils

proc getVer(): string {.compileTime.} =
  ## Returns parasite version string.
  let nimble = staticRead(Path(getProjectPath()).parentDir() / "parasite.nimble")
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
  BINDADDR* = "127.0.0.1"
  SCRIPTDIR* = getProjectPath()
  HTTPDIR* = SCRIPTDIR / "parasite" / "http"
  BULMACSS* = staticRead HTTPDIR / "bulma.min.css"
  HTMX* = staticRead HTTPDIR / "htmx.min.js"
  ARCH* = $(sizeof(int)*8)
  VER* = getVer()
  COMPILED* = getCompileEnv()