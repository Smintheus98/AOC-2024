import std / [ strutils, sequtils, math, tables ]
import parsecli

proc dec[A](t: var CountTable[A]; key: A; val = 1) = t[key] = t[key] - val

type
  Stone = int
  StoneLine = seq[Stone]

proc digLen(i: int): Natural =
  log10(i.float32).Natural + 1

proc blink(stone: Stone): StoneLine =
  if stone == 0:
    @[1]
  elif stone.digLen mod 2 == 0:
    let separator = 10 ^ (stone.digLen div 2)
    @[stone div separator, stone mod separator]
  else:
    @[stone * 2024]

proc blinkn(stones: StoneLine; n: Natural): Natural =
  var ct: CountTable[Stone] = stones.toCountTable
  for i in 0..<n:
    var tmp_ct = ct
    for stone in ct.keys:
      let stone_count = ct[stone]
      for st in stone.blink:
        tmp_ct.inc(st, stone_count)
      if tmp_ct[stone] == stone_count:
        tmp_ct.del(stone)
      else:
        tmp_ct.dec(stone, stone_count)
    ct = tmp_ct
  return ct.values.toSeq.sum


proc main =
  let input = getInputFile()
  let data = input.readFile.strip.splitWhitespace.map parseInt

  var stoneLine: StoneLine = data

  echo stoneLine.blinkn(75)

  quit QuitSuccess


when isMainModule:
  main()

