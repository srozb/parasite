import osproc

proc runShell*(cmd: string): (string, int) =
  ## Run shell command ``cmd`` and return its output and exit code
  let options: set[ProcessOption] = {poEvalCommand}
  var 
    lines: seq[string]
    exCode: int
    output: string
  try:
    let p = startProcess(cmd, options=options)
    (lines, exCode) = p.readLines
    p.close
  except OSError:
    return ("Error running command", -1)
  for l in lines.items:
    output.add(l & '\n')
  return (output, exCode)

when isMainModule:
  let (output, exCode) = runShell("cmd /c copy /?")
  echo $output
  echo "Command ended with code: " & $exCode
  