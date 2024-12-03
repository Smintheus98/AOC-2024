import std / [ strutils, sequtils ]
import parsecli

proc main =
  let input = getInputFile()

  #let data = input.readFile.strip
  #let lines = data.splitlines

  #for line in input.lines:
  #  discard


when isMainModule:
  main()
