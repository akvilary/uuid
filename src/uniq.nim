## RFC 9562 UUID library for Nim.
##
## Stack-allocated 16-byte UUIDs, versions 1, 3, 4, 5, 6, 7, 8.
##
## .. code-block:: nim
##   import uniq
##   let id = uuid4()
##   echo id                    # e.g. "550e8400-e29b-41d4-a716-446655440000"
##   let id7 = uuid7()          # sortable, time-based
##   assert id7.version == uver7

import uniq/types
export types

import uniq/parse
export parse

import uniq/v1
export v1

import uniq/v3
export v3

import uniq/v4
export v4

import uniq/v5
export v5

import uniq/v6
export v6

import uniq/v7
export v7

import uniq/v8
export v8
