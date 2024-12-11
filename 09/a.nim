import std / [ strutils, sequtils ]
import parsecli

type
  DiskMap = string
  FileBlock = object
    id: Natural
  MemBlock = object
    case occupied: bool:
      of true:
        fb: FileBlock
      of false:
        discard
  Disk = seq[MemBlock]

proc toDigit(c: char): int =
  assert c in '0'..'9'
  c.int - '0'.int

proc initDisk(dm: DiskMap): Disk =
  for i, c in dm:
    if i mod 2 == 0:
      for k in 0..<c.toDigit:
        result.add MemBlock(occupied: true, fb: FileBlock(id: i div 2))
    else:
      for k in 0..<c.toDigit:
        result.add MemBlock(occupied: false)

proc fragment(disk: var Disk) =
  var
    li = 0
    ri = disk.high
  while true:
    while not disk[ri].occupied:
      ri.dec
    while disk[li].occupied:
      li.inc
    if li >= ri:
      break
    swap(disk[li], disk[ri])

proc checksum(disk: Disk): Natural =
  for i, mb in disk:
    if mb.occupied:
      result += i * mb.fb.id

proc main =
  let input = getInputFile()
  let data: DiskMap = input.readFile.strip.DiskMap

  var disk = initDisk(data)
  disk.fragment

  echo disk.checksum



when isMainModule:
  main()
