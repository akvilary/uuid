## UUID version 1: time-based (Gregorian epoch).

import ./types
import ./timegen

proc uuid1*(): Uuid =
  ## Generates a version 1 UUID (time-based, random node).
  let (ts, clockSeq, node) = getTimestampAndClockSeq()
  var data: array[16, byte]
  # time_low: bits 0-31 of timestamp → bytes 0-3 (big-endian)
  data[0] = byte(ts shr 24)
  data[1] = byte(ts shr 16)
  data[2] = byte(ts shr 8)
  data[3] = byte(ts)
  # time_mid: bits 32-47 → bytes 4-5
  data[4] = byte(ts shr 40)
  data[5] = byte(ts shr 32)
  # time_hi_and_version: bits 48-59 → bytes 6-7 (version set later)
  data[6] = byte(ts shr 56)
  data[7] = byte(ts shr 48)
  # clock_seq_hi_and_variant + clock_seq_lo → bytes 8-9
  data[8] = byte(clockSeq shr 8)
  data[9] = byte(clockSeq)
  # node → bytes 10-15
  for i in 0 ..< 6:
    data[10 + i] = node[i]
  result = Uuid(data)
  setVersionAndVariant(result, 1)
