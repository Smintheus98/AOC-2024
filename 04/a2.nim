import std / [ strutils, sequtils, unicode ]
import parsecli
import textfield

type
  Filter = array[3, array[3, char]]
  FilterColl = seq[Filter]
  Position = tuple[r, c: int]

const filterColl: FilterColl = @[
  [['M', ' ', 'M'],
   [' ', 'A', ' '],
   ['S', ' ', 'S']],
  [['M', ' ', 'S'],
   [' ', 'A', ' '],
   ['M', ' ', 'S']],
  [['S', ' ', 'S'],
   [' ', 'A', ' '],
   ['M', ' ', 'M']],
  [['S', ' ', 'M'],
   [' ', 'A', ' '],
   ['S', ' ', 'M']],
]

proc check_filter(data: TextField; filterColl: FilterColl; pos_tl: Position): bool =
  for filter in filterColl:
    block local_filter:
      for r in 0..<filter.len:
        for c in 0..<filter[0].len:
          if filter[r][c] == ' ':
            continue
          if filter[r][c] != data[pos_tl.r + r][pos_tl.c + c]:
            break local_filter
      return true


proc main =
  let input = getInputFile()

  let data = input.readFile.strip.splitLines

  var occurences = 0
  for r in 0..data.len-filterColl[0].len:
    for c in 0..data[0].len-filterColl[0][0].len:
      if check_filter(data, filterColl, (r, c)):
        occurences.inc

  echo occurences

when isMainModule:
  main()
