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

proc blink_rec(startval: int; iter, max_iter, iter_step: Natural; res: var int) =
  var iter_step = min(iter_step, max_iter - iter)
  let iter = iter + iter_step
  var sl = @[startval]
  for it in 0..<iter_step:
    sl.blink_pseudoinplace
  if iter.succ >= max_iter:
    res += sl.len
    return
  for elem in sl:
    blink_rec(elem, iter, max_iter, iter_step, res)


proc blinkn_rec(sl: StoneLine; times: Natural; iter_step: Natural = 1): Natural =
  for startval in sl:
    echo "Start value: " & $startval
    startval.blink_rec(0, times, iter_step, result)

proc blinkn_rec_omp(sl: StoneLine; times: Natural; iter_step: Natural = 1): Natural =
  for i in `||`(0, sl.high, "parallel for reduction(+:result)"):
    let startval = sl[i]
    echo "Started for value: " & $startval
    startval.blink_rec(0, times, iter_step, result)
    echo "Ended for value: " & $startval


proc main =
  let input = getInputFile()
  let data = input.readFile.strip.splitWhitespace.map parseInt

  var stoneLine: StoneLine = data

  echo stoneLine.blinkn_rec_omp(75, 15)

  quit QuitSuccess


when isMainModule:
  main()

