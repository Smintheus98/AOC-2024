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
    else:
      # It's not very well designed or performant,
      # but quick to implement
      for i in 0..<report.len:
        var locReport = report
        locReport.delete(i)
        let lrd = locReport.diff()
        if (lrd.allIt(it > 0) and lrd.min >= 1 and lrd.max <= 3) or
            (lrd.allIt(it < 0) and lrd.max <= -1 and lrd.min >= -3):
          cnt.inc
          break

  echo cnt

when isMainModule:
  main()