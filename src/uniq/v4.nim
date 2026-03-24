## UUID version 4: random.

import std/sysrand
import ./types

proc uuid4*(): Uuid =
  ## Generates a version 4 (random) UUID.
  var data: array[16, byte]
  if not urandom(data):
    raise newException(OSError, "Failed to generate random bytes")
  result = Uuid(data)
  setVersionAndVariant(result, 4)
