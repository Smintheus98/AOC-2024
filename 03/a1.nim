import strutils, sequtils

type
  PatternInfo = tuple
    match: bool
    len: Natural

proc valid_pattern(s: string; pos: Natural): PatternInfo =
  const start_pattern_mul = "mul("
  var posp = pos

  if not s[posp..^1].startswith(start_pattern_mul):
    return (false, 0)
  posp += start_pattern_mul.len
  if not s[posp].isDigit:
    return (false, 0)
  for i in 2..4:
    posp.inc
    if s[posp] == ',':
      posp.inc
      break
    if not s[posp].isDigit or i == 4:
      return (false, 0)
  if not s[posp].isDigit:
    return (false, 0)
  for i in 2..4:
    posp.inc
    if s[posp] == ')':
      posp.inc
      break
    if not s[posp].isDigit or i == 4:
      return (false, 0)

  return (true, posp - pos)

proc parse_mul(s:string): int =
  let nums = s.split({ '(', ',', ')' })[1..2]
  result = nums.map(parseInt).foldl(a*b)

proc main =
  let input = "data.in"
  let data = input.readFile.strip

  var
    pos = 0
    mulsum = 0
  while pos < data.len:
    let pattern = data.valid_pattern(pos)
    if pattern.match:
      mulsum += data[pos..<pos+pattern.len].parse_mul
      pos += pattern.len
    else:
      pos.inc

  echo mulsum

when isMainModule:
  main()
