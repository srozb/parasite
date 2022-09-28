import winim

proc spawnProc*(procName: proc) =
  discard CreateThread(
    cast[LPSECURITY_ATTRIBUTES](NULL), 
    cast[SIZE_T](0), 
    cast[LPTHREAD_START_ROUTINE](procName), 
    cast[LPVOID](NULL), 
    cast[DWORD](NULL), 
    cast[LPDWORD](NULL)
  )