import std / [ strutils, sequtils, osproc, os ]
import parsecli

type
  LabMap = seq[seq[char]]
  Position = tuple
    row, col: int
  RelPosition = Position
  GuardDir = enum
    Up Right Down Left
  GuardState = enum
    Patrolling, Gone, Trapped

proc `[]`(labmap: LabMap; pos: Position): char = labmap[pos.row][pos.col]
proc `[]=`(labmap: var LabMap; pos: Position; val: char) = labmap[pos.row][pos.col] = val
proc show(labmap: LabMap) =
  for r in 0..<labmap.len:
    echo labmap[r].join("")
  echo ""

proc `+`(pos: Position; rel: RelPosition): Position = (pos.row + rel.row, pos.col + rel.col)

proc circsucc(dir: GuardDir): GuardDir = ((dir.ord + 1) mod GuardDir.toSeq.len).GuardDir
const dirRepr: array[GuardDir, char] = [ '^', '>', 'v', '<' ]
const dirPath: array[GuardDir, char] = [ '|', '-', '|', '-', ]
const relStep: array[GuardDir, RelPosition] = [ (-1,0), (0,1), (1,0), (0,-1) ]
converter dirToChar(dir: GuardDir): char = dirRepr[dir]
converter charToDir(c: char): GuardDir = dirRepr.find(c).GuardDir


proc find_guard(labmap: LabMap): Position =
  for row in 0..<labmap.len:
    for col in 0..<labmap[0].len:
      if labmap[row][col] in GuardDir.mapIt(it.dirToChar):
        return (row, col)
  return (-1, -1)

proc make_step(labmap: var LabMap; pos: var Position): GuardState =
  let dir = labmap[pos]
  labmap[pos] = dirPath[dir]
  let new_pos = pos + relStep[dir]
  if new_pos.row < 0 or new_pos.row > labmap.high or
     new_pos.col < 0 or new_pos.col > labmap[0].high:
    return Gone
  #elif labmap[new_pos] == dirPath[dir]:
  #  return Trapped
  elif labmap[new_pos] in { '#', 'O' }:
    labmap[pos] = dir.circsucc
    let curr_pos = pos
    if labmap[pos + relStep[dir.circsucc]] == dirPath[dir.circsucc]:
      return Trapped
    let state = make_step(labmap, pos)
    labmap[curr_pos] = '+'
    return state
  else:
    labmap[new_pos] = dir
    pos = new_pos
    return Patrolling


proc main =
  let input = getInputFile()
  let labmap: LabMap = input.readFile.strip.splitlines.mapIt(it.toSeq)

  var option_cnt = 0
  for r in 0..<labmap.len:
    for c in 0..<labmap[0].len:
      if labmap[(r,c)] == '#' or labmap[(r,c)] in dirRepr:
        continue
      var test_labmap = labmap
      var pos = find_guard(labmap)
      test_labmap[(r,c)] = 'O'
      while true:
        case test_labmap.make_step(pos):
          of Patrolling:
            continue
          of Gone:
            break
          of Trapped:
            option_cnt.inc
            break

  echo option_cnt



when isMainModule:
  main()
