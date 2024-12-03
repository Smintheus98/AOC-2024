import strutils, sequtils, algorithm, math, tables

type ListNum = enum
  List1, List2

proc main =
  var data: array[ListNum, seq[int]]

  for line in "input.txt".lines:
    let linedata = line.splitWhitespace
    for listNum in ListNum:
      data[listNum].add(linedata[listNum.int].parseInt)
  
  var cnttbl = initCountTable[int]()
  for loc in data[List1]:
    cnttbl[loc] = cnttbl[loc] + data[List2].count(loc)

  var similarityScore = 0
  for k, v in cnttbl:
    similarityScore += k * v

  echo similarityScore

  
when isMainModule:
  main()
