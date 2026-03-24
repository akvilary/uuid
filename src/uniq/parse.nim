## UUID string parsing and formatting.

import ./types

const
  hexChars = "0123456789abcdef"
  dashPositions = [8, 13, 18, 23]

proc `$`*(u: Uuid): string =
  ## Formats UUID as lowercase "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx".
  result = newString(36)
  let data = u.bytes
  var pos = 0
  for i in 0 ..< 16:
    if pos == 8 or pos == 13 or pos == 18 or pos == 23:
      result[pos] = '-'
      inc pos
    result[pos] = hexChars[data[i] shr 4]
    result[pos + 1] = hexChars[data[i] and 0x0F]
    pos += 2

proc hexVal(c: char): int {.inline.} =
  case c
  of '0'..'9': ord(c) - ord('0')
  of 'a'..'f': ord(c) - ord('a') + 10
  of 'A'..'F': ord(c) - ord('A') + 10
  else: -1

proc tryParseUuid*(s: string, output: var Uuid): bool =
  ## Non-raising parse. Returns false on invalid input.
  if s.len != 36:
    return false
  for dp in dashPositions:
    if s[dp] != '-':
      return false
  var data: array[16, byte]
  var byteIdx = 0
  var i = 0
  while i < 36:
    if i == 8 or i == 13 or i == 18 or i == 23:
      inc i
      continue
    let hi = hexVal(s[i])
    let lo = hexVal(s[i + 1])
    if hi < 0 or lo < 0:
      return false
    data[byteIdx] = byte((hi shl 4) or lo)
    inc byteIdx
    i += 2
  output = toUuid(data)
  true

proc parseUuid*(s: string): Uuid =
  ## Parses UUID from "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" format.
  ## Raises ValueError on invalid input.
  if not tryParseUuid(s, result):
    raise newException(ValueError, "Invalid UUID string: " & s)
