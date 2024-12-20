import std / [ strutils, sequtils, unicode ]
import parsecli
import textfield

const sword = "XMAS"

proc transpose(data: TextField): TextField = 
  result = newSeq[string](data[0].len)
  for i in 0..data.high:
    for j in 0..data[0].high:
      result[j].add(data[i][j])

proc tilt_l(data: TextField): TextField =
  result = newSeq[string](data.len + data[0].len - 1)
  for r in 0..<data[0].high:
    for k in 0..r:
      result[r].add data[k][data[0].high-r+k]
  for i in 0..data.len-data[0].len:
    for j in 0..<min(data.len,data[0].len):
      result[data[0].len+i-1].add data[i+j][j]
  for c in data.len-data[0].high..data[0].high:
    for k in 0..<data[0].len-c:
      result[data[0].high+c].add data[c+k][k]

proc tilt_r(data: TextField): TextField =
  result = newSeq[string](data.len + data[0].len - 1)
  for c in 0..<data[0].high:
    for k in 0..c:
      result[c].add data[k][c-k]
  for i in 0..data.len-data[0].len:
    for j in 0..<min(data.len,data[0].len):
      result[data[0].len+i-1].add data[i+j][data[0].high-j]
  for c in data.len-data[0].high..data[0].high:
    for k in 0..<data[0].len-c:
      result[data[0].high+c].add data[c+k][data[0].high-k]


proc count_h(data: TextField): Natural =
  result = 0
  for line in data:
    var pos = 0
    while true:
      let npos = find(line, sword, pos)
      if npos == -1:
        break
      result.inc
      pos = npos+1
    pos = 0
    while true:
      let npos = find(line, sword.reversed, pos)
      if npos == -1:
        break
      result.inc
      pos = npos+1

proc count_v(data: TextField): Natural =
  let data = data.transpose
  return count_h(data)

proc count_tlbr(data:TextField): Natural =
  let data = data.tilt_l
  return count_h(data)

proc count_trbl(data:TextField): Natural =
  let data = data.tilt_r
  return count_h(data)

proc main =
  let input = getInputFile()

  let data = input.readFile.strip.splitlines #.mapIt(it.toSeq).toTensor

  let occurences =
      data.count_h + data.count_v + data.count_trbl + data.count_tlbr

  echo occurences

when isMainModule:
  main()
