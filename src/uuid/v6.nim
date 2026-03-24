## UUID version 6: reordered time-based (sortable).

import ./types
import ./timegen

proc uuidv6*(): Uuid =
  ## Generates a version 6 UUID (reordered time-based, sortable).
  let (ts, clockSeq, node) = getTimestampAndClockSeq()
  var data: array[16, byte]
  # time_high: bits 28-59 of timestamp → bytes 0-3
  data[0] = byte(ts shr 52)
  data[1] = byte(ts shr 44)
  data[2] = byte(ts shr 36)
  data[3] = byte(ts shr 28)
  # time_mid: bits 16-27 → bytes 4-5
  data[4] = byte(ts shr 20)
  data[5] = byte(ts shr 12)
  # time_low_and_version: bits 12-15 → byte 6 lower nibble (version set later)
  # bits 4-11 → byte 7
  data[6] = byte(ts shr 8) and 0x0F
  data[7] = byte(ts)
  # clock_seq → bytes 8-9
  data[8] = byte(clockSeq shr 8)
  data[9] = byte(clockSeq)
  # node → bytes 10-15
  for i in 0 ..< 6:
    data[10 + i] = node[i]
  result = Uuid(data)
  setVersionAndVariant(result, 6)
