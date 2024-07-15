when isMainModule:
  import os
  import strutils
  import parasite/dumper
  if paramCount() != 2:
    echo "usage: dumper <pid> <dump filename>"
    quit(-1)
  var res = dumpToFile(paramStr(1).parseInt(), paramStr(2))
  echo "All done. Success:" & $res
