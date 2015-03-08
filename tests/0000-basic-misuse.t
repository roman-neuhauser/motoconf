wrong operand counts, unknown options, missing files
====================================================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ motoconf
  motoconf: usage: motoconf -h | --help
  motoconf: usage: motoconf -c INPUT
  motoconf: usage: motoconf INPUT [--prefix=PFX] [NAME=VALUE...]
  [1]

  $ motoconf fubar
  motoconf: fubar: file not found
  [1]

  $ motoconf --fubar
  motoconf: --fubar: file not found
  [1]

