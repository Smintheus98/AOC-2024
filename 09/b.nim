import std / [ strformat, strutils, sequtils ]
import parsecli

type
  DiskMap = string
  MemArea = object
    len: Natural
    case occupied: bool:
      of true: fileId: Natural
      of false: discard
  Disk = seq[MemArea]

proc toDigit(c: char): int =
  assert c in '0'..'9'
  c.int - '0'.int

proc initDisk(dm: DiskMap): Disk =
  for i, c in dm:
    if i mod 2 == 0:
      result.add MemArea(len: c.toDigit, occupied: true, fileId: i div 2)
    else:
      result.add MemArea(len: c.toDigit, occupied: false)

proc `$`(disk: Disk): string =
  for ma in disk:
    if ma.occupied:
      result.add "(" & $ma.fileId.`$`.repeat(ma.len) & ")"
    else:
      result.add ".".repeat(ma.len)

proc merge(disk: var Disk): int =
  var i = 0
  while i < disk.high:
    if not disk[i].occupied and not disk[i.succ].occupied:
      disk[i].len += disk[i.succ].len
      disk.delete(i.succ)
      result.inc
    else:
      i.inc


proc defragment(disk: var Disk) =
  var
    li = 0
    ri = disk.high
  while true:
    while ri >= 0 and not disk[ri].occupied:
      ri.dec
    if ri < 0:
      break
    li = 0
    while li < ri and (disk[li].occupied or disk[li].len < disk[ri].len):
      li.inc
    if li >= ri:
      ri.dec
      continue
    if disk[li].len > disk[ri].len:
      disk[li].len -= disk[ri].len 
      disk.insert(MemArea(len: disk[ri].len, occupied: false), li)
      ri.inc
    swap(disk[li], disk[ri])
    ri.dec disk.merge

proc checksum(disk: Disk): Natural =
  var i = 0
  for ma in disk:
    if ma.occupied:
      for k in 0..<ma.len:
        result += (i+k) * ma.fileId
    i.inc ma.len

proc main =
  let input = getInputFile()
  let data: DiskMap = input.readFile.strip.DiskMap

  var disk = initDisk(data)
  disk.defragment

  echo disk.checksum



when isMainModule:
  main()
