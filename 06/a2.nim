import std / [ strformat, strutils, sequtils, osproc, os ]
import parsecli

type
  Position = tuple
    row, col: int
  RelPosition = Position
  Direction = enum
    Up, Right, Down, Left

proc `+`(pos: Position; rel: RelPosition): Position = (pos.row + rel.row, pos.col + rel.col)
proc rotsucc(dir: Direction): Direction = ((dir.ord + 1) mod Direction.toSeq.len).Direction

type 
  LabElement = uint8 # 0-3: crossed in direction of `GuardDir`, 4/5: is not crossable (normal/placed obstacle)
  Lab = seq[seq[LabElement]]

converter toLabElement(c: char): LabElement =
  case c:
    of '#': return 1'u8 shl 4
    of 'O': return 1'u8 shl 5
    of '.': return 0'u8
    else:   return 0'u8

proc normalObstacle(elem: LabElement): bool = (elem and (1 shl 4)).bool
proc placedObstacle(elem: LabElement): bool = (elem and (1 shl 5)).bool
proc crossable(elem: LabElement): bool = not (elem.normalObstacle or elem.placedObstacle)
proc crossInDir(elem: var LabElement; dir: Direction) = elem = elem or (1'u8 shl dir.ord)
proc crossed(elem: LabElement): bool = (elem and ((1'u8 shl 4) - 1)).bool
proc crossedInDir(elem: LabElement; dir: Direction): bool = (elem and (1'u8 shl dir.ord)).bool

proc initLab(nRows, nCols: Natural): Lab = newSeqWith(nRows, newSeqOfCap[LabElement](nCols))
proc `[]`(lab: Lab; pos: Position): LabElement = lab[pos.row][pos.col]
proc `[]`(lab: var Lab; pos: Position): var LabElement = lab[pos.row][pos.col]
proc `[]=`(lab: var Lab; pos: Position; val: uint8) = lab[pos.row][pos.col] = val
proc contained(lab: Lab; pos: Position): bool = pos.row >= 0 and pos.row < lab.len and pos.col >= 0 and pos.col < lab[0].len
proc numberCrossed(lab: Lab): Natural = lab.mapIt(it.countIt(it.crossed)).foldl(a+b)
proc show(lab: Lab; os: File = stdout) =
  for r in 0..<lab.len:
    for c in 0..<lab[0].len:
      let elem = lab[(r,c)]
      var ec: char
      if elem.placedObstacle: ec = 'O'
      elif not elem.crossable: ec = '#'
      elif not elem.crossed: ec = '.'
      else: ec = 'X'
      os.write(ec)
    os.writeLine("")

type
  GuardState = enum
    Patrolling, Gone, Trapped
  Guard = object
    pos: Position
    dir: Direction
    state: GuardState

proc initGuard(pos: Position; dir: Direction): Guard =
  result.pos = pos
  result.dir = dir
  result.state = Patrolling

proc initGuard(pos: Position; dirChar: char): Guard =
  var dir: Direction
  case dirChar:
    of '^': dir = Up
    of '>': dir = Right
    of 'v': dir = Down
    of '<': dir = Left
    else: raise newException(IOError, "Invalid guard character!: '" & dirChar & "'")
  initGuard(pos, dir)

proc turnRight(guard: var Guard) = guard.dir = guard.dir.rotsucc

const dirRepr: array[Direction, char] = [ '^', '>', 'v', '<' ]
const stepOptions: array[Direction, RelPosition] = [ (-1,0), (0,1), (1,0), (0,-1) ]

type
  LabGuard = tuple
    lab: Lab
    guard: Guard

proc makeStep(lab: var Lab; guard: var Guard) =
  let nextPos = guard.pos + stepOptions[guard.dir]
  if not lab.contained(nextPos):
    guard.pos = nextPos
    guard.state = Gone
  elif not lab[nextPos].crossable:
    guard.turnRight
    lab[guard.pos].crossInDir(guard.dir)
  elif lab[nextPos].crossedInDir(guard.dir):
    guard.pos = nextPos
    guard.state = Trapped
  else:
    guard.pos = nextPos
    lab[nextPos].crossInDir(guard.dir)

proc makeStep(lg: var LabGuard) = makeStep(lg.lab, lg.guard)
 
proc parseLab(data: seq[seq[char]]): LabGuard =
  result.lab = initLab(data.len, data[0].len)
  for row in 0..<data.len:
    for col in 0..<data[0].len:
      let c = data[row][col]
      if c in dirRepr:
        result.guard = initGuard((row,col), c)
        result.lab[row].add '.'.toLabElement
        result.lab[(row,col)].crossInDir(result.guard.dir)
      else:
        result.lab[row].add c.toLabElement

proc tryObstacle(lg: LabGuard; pos: Position): bool =
  var lg = lg
  lg.lab[pos] = 'O'.toLabElement
  while lg.guard.state == Patrolling:
    lg.makeStep
  return lg.guard.state == Trapped

proc findAllObstaclePos(lg: LabGuard): Natural =
  var clg = lg
  while clg.guard.state != Gone:
    clg.makeStep
  result = 0
  for r in 0..<lg.lab.len:
    for c in 0..<lg.lab[0].len:
      if not clg.lab[(r,c)].crossed or (r,c) == lg.guard.pos:
        continue
      else:
        if tryObstacle(lg, (r,c)):
          result.inc


proc main =
  let
    input = getInputFile()
    data = input.readFile.strip.splitlines.mapIt(it.toSeq)
    labGuard = data.parseLab

  echo findAllObstaclePos(labGuard)


when isMainModule:
  main()
