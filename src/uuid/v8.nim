## UUID version 8: custom/vendor-specific.

import ./types

proc uuidv8*(data: array[16, byte]): Uuid =
  ## Generates a version 8 UUID from raw bytes.
  ## Forces version=8 and variant=RFC9562 (overwrites 6 of 128 bits).
  result = Uuid(data)
  setVersionAndVariant(result, 8)

proc uuidv8*(customA, customB: uint64): Uuid =
  ## Generates a version 8 UUID from two 64-bit values.
  ## customA fills bytes 0-7, customB fills bytes 8-15.
  ## Version and variant bits are forced.
  var data: array[16, byte]
  data[0] = byte(customA shr 56)
  data[1] = byte(customA shr 48)
  data[2] = byte(customA shr 40)
  data[3] = byte(customA shr 32)
  data[4] = byte(customA shr 24)
  data[5] = byte(customA shr 16)
  data[6] = byte(customA shr 8)
  data[7] = byte(customA)
  data[8] = byte(customB shr 56)
  data[9] = byte(customB shr 48)
  data[10] = byte(customB shr 40)
  data[11] = byte(customB shr 32)
  data[12] = byte(customB shr 24)
  data[13] = byte(customB shr 16)
  data[14] = byte(customB shr 8)
  data[15] = byte(customB)
  result = Uuid(data)
  setVersionAndVariant(result, 8)
