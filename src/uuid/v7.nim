## UUID version 7: Unix epoch time-based + random (sortable).

import std/[times, sysrand]
import ./types

proc uuidv7*(): Uuid =
  ## Generates a version 7 UUID (48-bit Unix ms timestamp + random).
  let now = getTime()
  let ms = uint64(now.toUnix) * 1000'u64 + uint64(now.nanosecond div 1_000_000)
  var data: array[16, byte]
  # 48-bit ms timestamp → bytes 0-5 (big-endian)
  data[0] = byte(ms shr 40)
  data[1] = byte(ms shr 32)
  data[2] = byte(ms shr 24)
  data[3] = byte(ms shr 16)
  data[4] = byte(ms shr 8)
  data[5] = byte(ms)
  # Random fill for bytes 6-15
  var randBuf: array[10, byte]
  if not urandom(randBuf):
    raise newException(OSError, "Failed to generate random bytes")
  for i in 0 ..< 10:
    data[6 + i] = randBuf[i]
  result = Uuid(data)
  setVersionAndVariant(result, 7)
