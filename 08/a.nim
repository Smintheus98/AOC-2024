import std / [ strutils, sequtils, sets ]
import parsecli

type
  Location = tuple
    r, c: int
  Distance = tuple
    r, c: int
  Frequency = char
  Antenna = object
    loc: Location
    freq: Frequency
  Map = object
    nr, nc: Natural
    antennas: seq[Antenna]
    antinodes: HashSet[Location]

proc initMap(data: seq[string]): Map =
  result.nr = data.len
  result.nc = data[0].len
  for r in 0..<data.len:
    for c in 0..<data[0].len:
      if data[r][c] == '.':
        continue
      else:
        result.antennas.add Antenna(loc: (r,c), freq: data[r][c])

proc contains(map: Map; loc: Location): bool = loc.r >= 0 and loc.r < map.nr and loc.c >= 0 and loc.c < map.nc

proc `-`(l1, l2: Location): Distance = (l1.r - l2.r, l1.c - l2.c)

proc getFreqs(map: Map): seq[Frequency] =
  for ant in map.antennas:
    if ant.freq notin result:
      result.add ant.freq

proc main =
  let
    input = getInputFile()
    data = input.readFile.strip.splitLines
  var map = data.initMap

  for freq in map.getFreqs:
    let ants = map.antennas.filterIt(it.freq == freq)
    for ant1 in ants:
      for ant2 in ants:
        if ant1 == ant2: continue
        let diff = ant1.loc - ant2.loc
        let antinodeLoc = ant2.loc - diff
        if antinodeLoc in map:
          map.antinodes.incl antinodeLoc

  echo map.antinodes.len

when isMainModule:
  main()
