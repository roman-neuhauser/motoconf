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
  *: unbound variable (glob)
  [1]

  $ motoconf fubar
  motoconf: fubar: file not found
  [1]

  $ motoconf --fubar
  motoconf: --fubar: file not found
  [1]

