import std / [ strformat, cmdline ]

type
  ParameterError* = object of IOError
  Input* = enum
    ExampleInput = "example.in", DataInput = "data.in"

const DefaultFile = DataInput

proc getInputFile*(): string =
  let cli = commandLineParams()
  var idx = 0
  while idx < cli.len:
    case cli[idx]:
      of "-i", "--in":
        if result != "":
          raise newException(ParameterError, "Multiple input files given")
        result = cli[idx+1]
        idx.inc 2
      of "-h", "--help":
        echo "Usage: <exe> --in|-i <inputdatafile>"
        quit QuitSuccess
      else:
        raise newException(ParameterError, fmt"Unknown command line option: '{cli[idx]}'")
  if result == "":
    result = $DefaultFile

