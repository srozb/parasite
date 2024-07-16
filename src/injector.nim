when isMainModule:
  import os
  import strutils
  import parasite/dllinject

  if paramCount() != 2:
    echo "usage: injector <pid> <dll>"
    quit(-1)
  injectModule(paramStr(1).parseInt(), paramStr(2))
  echo "All done."
  