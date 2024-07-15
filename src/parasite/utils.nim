import std/paths

proc `/`*(a, b: Path|string): string {.compileTime.} = string(Path(a) / Path(b))