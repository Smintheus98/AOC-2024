
type TextField* = seq[string]

proc `$`*(f: TextField): string =
  result = ""
  for line in f:
    result.add line & '\n'
