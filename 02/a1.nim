import sequtils, strutils


proc diff(s: seq[int]): seq[int] =
  toSeq(0..s.high-1).mapIt(s[it] - s[it+1])

proc main =
  var cnt = 0
  for line in "data.in".lines:
    let report = line.splitWhitespace.map(parseInt)
    let rd = report.diff
    if (rd.allIt(it > 0) and rd.min >= 1 and rd.max <= 3) or
        (rd.allIt(it < 0) and rd.max <= -1 and rd.min >= -3):
      cnt.inc

  echo cnt

when isMainModule:
  main()
