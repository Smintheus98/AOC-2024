import strutils, sequtils, algorithm, math

# not very nice and incomplete; probably more performant though
#let input: seq[string] = "input.txt".readFile.strip.splitLines
#let data = input --> map(it.split() --> map(it.parseInt))

type ListNum = enum
  List1, List2

proc main =
  var data: array[ListNum, seq[int]]

  for line in "input.txt".lines:
    let linedata = line.splitWhitespace
    for listNum in ListNum:
      data[listNum].add(linedata[listNum.int].parseInt)
  
  for listNum in ListNum:
    data[listNum].sort()
  
  var distance = newSeqofCap[int](data[0.ListNum].len)
  for pair in zip(data[List1], data[List2]):
    distance.add abs(pair[List1.int] - pair[List2.int])

  let totalDistance = distance.sum()
  echo totalDistance


when isMainModule:
  main()
