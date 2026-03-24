## RFC 9562 UUID library for Nim.
##
## Stack-allocated 16-byte UUIDs, versions 1, 3, 4, 5, 6, 7, 8.
##
## .. code-block:: nim
##   import uuid
##   let id = uuid4()
##   echo id                    # e.g. "550e8400-e29b-41d4-a716-446655440000"
##   let id7 = uuid7()          # sortable, time-based
##   assert id7.version == uvV7

import uuid/types
export types

import uuid/parse
export parse

import uuid/v1
export v1

import uuid/v3
export v3

import uuid/v4
export v4

import uuid/v5
export v5

import uuid/v6
export v6

import uuid/v7
export v7

import uuid/v8
export v8
