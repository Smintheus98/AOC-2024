import std / [ strutils, sequtils, sets, math ]
import parsecli

type
  Direction = enum
    Up, Left, Down, Right
  Position = tuple
    row, col: int
  Step = tuple
    row, col: int
  Level = range[0..9]
  TrailHead = Position
  Map = object
    nrow, ncol: Natural
    data: seq[seq[Level]]
    trailHeads: seq[TrailHead]

proc `+`(p: Position; s: Step): Position = (p.row + s.row, p.col + s.col)

converter DirToStep(dir: Direction): Step =
  case dir:
    of Up:    (-1,  0)
    of Left:  ( 0, -1)
    of Down:  ( 1,  0)
    of Right: ( 0,  1)

converter charToLevel(c: char): Level =
  assert c in '0'..'9'
  (c.int - '0'.int).Level

proc initMap(data: seq[seq[Level]]): Map =
  result.nrow = data.len
  result.ncol = data[0].len
  result.data = data
  result.trailHeads = @[]
  for r in 0..<result.nrow:
    for c in 0..<result.ncol:
      if data[r][c] == 0:
        result.trailHeads.add (r, c)

proc contains(map: Map; pos: Position): bool = pos.row >= 0 and pos.row < map.nrow and pos.col >= 0 and pos.col < map.ncol
proc `[]`(map: Map; pos: Position): Level = map.data[pos.row][pos.col]
proc `[]`(map: var Map; pos: Position): var Level = map.data[pos.row][pos.col]
proc `[]=`(map: var Map; pos: Position; level: Level) = map.data[pos.row][pos.col] = level

proc findTops(map: Map; pos: Position): HashSet[Position] =
  if map[pos] == 9:
    return @[pos].toHashSet
  for dir in Direction:
    if pos+dir in map and map[pos+dir] - map[pos] == 1:
      result.incl map.findTops(pos + dir)

proc scores(map: Map): seq[Natural] =
  for th in map.trailHeads:
    result.add map.findTops(th).len


proc main =
  let input = getInputFile()

  let data = input.readFile.strip.splitlines.mapIt(it.map(charToLevel))
  var map = data.initMap

  echo map.scores.sum



  #for line in input.lines:
  #  discard


when isMainModule:
  main()
