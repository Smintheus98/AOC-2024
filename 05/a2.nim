import std / [ strutils, sequtils, tables ]
import parsecli

type
  RuleTable = Table[int, seq[int]]
  Update = seq[int]
  InputSection = enum
    RuleSection, UpdateSection

proc addDep(rt: var RuleTable; page, dependency: int) =
  if rt.hasKey(page):
    rt[page].add dependency
  else:
    rt[page] = @[dependency]

proc check(update: Update; rules: RuleTable): bool =
  for i, page in update:
    if not rules.hasKey(page):
      continue
    for j in i+1..<update.len:
      if update[j] in rules[page]:
        return false
  return true

proc correct(update: var Update; rules: RuleTable) =
  while not update.check(rules):
    block try_correct_update:
      for i, page in update.mpairs:
        if not rules.hasKey(page):
          continue
        for j in i+1..<update.len:
          if update[j] in rules[page]:
            let wrong_page = update[j]
            update.delete(j)
            update.insert(wrong_page, i)
            break try_correct_update


proc midval(update: Update): int =
  update[update.len div 2]

proc main =
  let input = getInputFile()

  var rules: RuleTable
  var updates: seq[Update]

  # parse input
  var section = InputSection.RuleSection
  for line in input.lines:
    if line == "":
      section = InputSection.UpdateSection
      continue
    case section:
      of RuleSection:
        let page_nrs = line.split('|').mapIt(it.parseInt)
        rules.addDep(page_nrs[1], page_nrs[0])
      of UpdateSection:
        updates.add line.split(',').mapIt(it.parseInt)
    
  # calculate
  var sum = 0
  for update in updates.mitems:
    if not update.check(rules):
      update.correct(rules)
      sum += update.midval

  echo sum



when isMainModule:
  main()
