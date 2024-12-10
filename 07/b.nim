import std / [ strutils, sequtils, math ]
import parsecli

type
  Op = enum
    Add, Multiply, Concat
  Test = object
    value: Natural
    factors: seq[Natural]

proc `||`(a, b: Natural): Natural =
  a * (10^(log(b.float, 10.0).int + 1)) + b
  #parseInt($a & $b).Natural

proc apply(a, b: int; op: Op): int =
  case op:
    of Add:       a + b
    of Multiply:  a * b
    of Concat:    a || b

proc apply(vals: seq[Natural]; ops: seq[Op]): int =
  var accu = vals[0]
  for i, val in vals[1..^1]:
    accu = apply(accu, val , ops[i])
  return accu

proc opPerms(num: Natural; ops: seq[Op]): seq[seq[Op]] =
  proc valToPerm(val: Natural; ops: seq[Op]; len: Natural): seq[Op] =
    var val = val
    result = newSeq[Op](len)
    for k in 0..<len:
      result[k] = ops[val mod ops.len]
      val = val div ops.len

  result = newSeqWith(ops.len^num, newSeq[Op]())
  for i in 0..<result.len:
    result[i] = valToPerm(i, ops, num)

proc isValid(test: Test; ops: seq[Op]): bool =
  let opsPerms = opPerms(test.factors.len - 1, ops)
  for opsPerm in opsPerms:
    if test.value == test.factors.apply(opsPerm):
      return true
  return false

proc main =
  let input = getInputFile()

  let ops = @[Add, Multiply, Concat]

  var testValue = 0
  for line in input.lines:
    let lelems = line.split(':').mapIt(it.strip)
    let test = Test(
        value: lelems[0].parseInt,
        factors: lelems[1].splitWhitespace.mapIt(it.parseInt.Natural)
      )
    if test.isValid(ops):
      testValue += test.value


  echo testValue


when isMainModule:
  main()
