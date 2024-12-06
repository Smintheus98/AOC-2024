import std / [ strutils, sequtils ]
import parsecli

type
  LabMap = seq[seq[char]]
  Position = tuple
    row, col: int
  RelPosition = Position
  GuardDir = enum
    Up Right Down Left

proc `[]`(labmap: LabMap; pos: Position): char = labmap[pos.row][pos.col]
proc `[]=`(labmap: var LabMap; pos: Position; val: char) = labmap[pos.row][pos.col] = val
proc show(labmap: LabMap) =
  for r in 0..<labmap.len:
    echo labmap[r].join("")
  echo ""


proc `+`(pos: Position; rel: RelPosition): Position = (pos.row + rel.row, pos.col + rel.col)

proc circsucc(dir: GuardDir): GuardDir = ((dir.ord + 1) mod GuardDir.toSeq.len).GuardDir
const dirRepr: array[GuardDir, char] = [ '^', '>', 'v', '<' ]
const relStep: array[GuardDir, RelPosition] = [ (-1,0), (0,1), (1,0), (0,-1) ]
converter dirToChar(dir: GuardDir): char = dirRepr[dir]
converter charToDir(c: char): GuardDir = dirRepr.find(c).GuardDir


proc find_guard(labmap: LabMap): Position =
  for row in 0..<labmap.len:
    for col in 0..<labmap[0].len:
      if labmap[row][col] in GuardDir.mapIt(it.dirToChar):
        return (row, col)
  return (-1, -1)

proc make_step(labmap: var LabMap; pos: var Position): bool =
  let dir = labmap[pos]
  labmap[pos] = 'X'
  let new_pos = pos + relStep[dir]
  if new_pos.row < 0 or new_pos.row > labmap.high or
     new_pos.col < 0 or new_pos.col > labmap[0].high:
    return false
  elif labmap[new_pos] == '#':
    labmap[pos] = dir.circsucc
  else:
    labmap[new_pos] = dir
    pos = new_pos
  return true


proc main =
  let input = getInputFile()
  var labmap: LabMap = input.readFile.strip.splitlines.mapIt(it.toSeq)

  var pos = find_guard(labmap)
  while true:
    if not labmap.make_step(pos):
      break
    #execCmd("clear")
    #labmap.show
    #sleep(10)
    discard

  echo labmap.mapIt(it.count('X')).foldl(a+b)


when isMainModule:
  main()
