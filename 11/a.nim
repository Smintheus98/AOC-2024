import std / [ strutils, sequtils, math, lists ]
import parsecli

proc digLen(i: int): Natural =
  log10(i.float).Natural + 1


## Notes:
##  Machine: `Thinkpad-P15s-Gen-1` with `Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz`
##   Number of Blinks: 25
##    seq_inplace: by far the slowest version, taking about 4.4 seconds
##    seq_copy/seq_pseudoinplace: fastest versions with about equal performance around 0.02 seconds
##    list_inplace: takes about three times the time of the fastest version (0.06 seconds)
##    #Blinks:            25      40    50
##    ----------------------------------------
##    seq_inplace         4.4s    >2m
##    seq_copy            0.02s   5.5s  >3m->out of memory
##    seq_pseudoinplace   0.02s   5.7s
##    list_inplace        0.06s  20.5s
##
const USE_LINKED_LIST = false

when USE_LINKED_LIST:

  type StoneLine = SinglyLinkedList[int]

  proc len(sl: StoneLine): Natural =
    for node in sl.nodes:
      result.inc

  proc insert[T](sl: var StoneLine; value: T; after: SinglyLinkedNode[T]) =
    let newNode = newSinglyLinkedNode(value)
    newNode.next = after.next
    after.next = newNode
    if sl.tail == after:
      sl.tail = newNode

  proc blink_inplace(sl: var StoneLine) =
    var node = sl.head
    while node != nil:
      if node.value == 0:
        node.value = 1
      elif node.value.digLen mod 2 == 0:
        let separator = 10 ^ (node.value.digLen div 2)
        sl.insert(node.value mod separator, node)
        node.value = node.value div separator
        node = node.next
      else:
        node.value *= 2024
      node = node.next

else:

  type StoneLine = seq[int]

  proc blink_inplace(sl: var StoneLine) =
    var i = 0
    while i < sl.len:
      if sl[i] == 0:
        sl[i] = 1
      elif sl[i].digLen mod 2 == 0:
        let separator = 10 ^ (sl[i].digLen div 2)
        sl.insert(sl[i] mod separator, i.succ)
        sl[i] = sl[i] div separator
        i.inc
      else:
        sl[i] *= 2024
      i.inc

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

# end when



proc main =
  let input = getInputFile()
  let data = input.readFile.strip.splitWhitespace.map parseInt

  when USE_LINKED_LIST:
    var stoneLine = data.toSinglyLinkedList
  else:
    var stoneLine = data
  # end when

  for i in 0..<25:
    echo "Step: " & $i
    when USE_LINKED_LIST:
      stoneLine.blink_inplace
    else:
      stoneLine = stoneLine.blink_copy
    # end when

  echo stoneLine.len

  quit QuitSuccess


when isMainModule:
  main()

