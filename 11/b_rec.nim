import std / [ strutils, sequtils, math ]
import parsecli

type StoneLine = seq[int]

proc digLen(i: int): Natural =
  log10(i.float32).Natural + 1

proc blink_pseudoinplace(sl: var StoneLine) =
  var buf: StoneLine = @[]
  for stone in sl:
    if stone == 0:
      buf.add 1
    elif stone.digLen mod 2 == 0:
      let separator = 10 ^ (stone.digLen div 2)
      buf.add stone div separator
      buf.add stone mod separator
    else:
      buf.add stone * 2024
  sl = buf

proc blink_copy(sl: StoneLine): StoneLine =
  result = @[]
  for stone in sl:
    if stone == 0:
      result.add 1
    elif stone.digLen mod 2 == 0:
      let separator = 10 ^ (stone.digLen div 2)
      result.add stone div separator
      result.add stone mod separator
    else:
      result.add stone * 2024

proc blink_rec(startval: int; iter, max_iter: Natural; res: var Natural) =
  if iter == max_iter:
    return
  for elem in @[startval].blink_copy:
    blink_rec(elem, iter.pred, max_iter, res)


proc blinkn_rec(sl: StoneLine; times: Natural): Natural =
  for startval in sl:
    echo "Start value: " & $startval
    result += startval.blink_rec(startval, 0.Natural, times, result)


proc main =
  let input = getInputFile()
  let data = input.readFile.strip.splitWhitespace.map parseInt

  var stoneLine: StoneLine = data

  echo stoneLine.blink_memory_efficient(50)

  quit QuitSuccess


when isMainModule:
  main()

