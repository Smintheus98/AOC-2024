import strutils, sequtils

type
  PatternKind = enum
    None, Do, Mul, Dont

  PatternInfo = tuple
    match: bool
    kind: PatternKind
    len: Natural

proc valid_pattern(s: string; pos: Natural): PatternInfo =
  if s[pos..^1].startswith("do()"):
    return (true, Do, 4)
  if s[pos..^1].startswith("don't()"):
    return (true, Dont, 7)

  const start_pattern_mul = "mul("
  var posp = pos

  if not s[posp..^1].startswith(start_pattern_mul):
    return (false, None, 0)
  posp += start_pattern_mul.len
  if not s[posp].isDigit:
    return (false, None, 0)
  for i in 2..4:
    posp.inc
    if s[posp] == ',':
      posp.inc
      break
    if not s[posp].isDigit or i == 4:
      return (false, None, 0)
  if not s[posp].isDigit:
    return (false, None, 0)
  for i in 2..4:
    posp.inc
    if s[posp] == ')':
      posp.inc
      break
    if not s[posp].isDigit or i == 4:
      return (false, None, 0)

  return (true, Mul, posp - pos)

proc parse_mul(s:string): int =
  let nums = s.split({ '(', ',', ')' })[1..2]
  result = nums.map(parseInt).foldl(a*b)

proc main =
  let input = "data.in"
  let data = input.readFile.strip

  var
    pos = 0
    mulsum = 0
    do_mul = true
  while pos < data.len:
    let pattern = data.valid_pattern(pos)
    if pattern.match:
      case pattern.kind:
        of None:
          discard
        of Do:
          do_mul = true
        of Mul:
          if do_mul:
            mulsum += data[pos..<pos+pattern.len].parse_mul
        of Dont:
          do_mul = false
      pos += pattern.len
    else:
      pos.inc

  echo mulsum





when isMainModule:
  main()
