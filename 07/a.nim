import std / [ strutils, sequtils ]
import parsecli

type Op = enum
  Add, Multiply

proc apply(a, b: int; op: Op): int =
  case op:
    of Add:
      a + b
    of Multiply:
      a * b

proc apply(vals: seq[int]; ops: seq[Op]): int =
  discard


proc main =
  let input = getInputFile()

  for line in input.lines:
    discard


when isMainModule:
  main()
