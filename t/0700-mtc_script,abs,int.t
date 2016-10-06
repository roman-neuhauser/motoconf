mtc_create_script
=================

setup
*****

::

  $ . $TESTDIR/setup

  $ rules=moto.rules

  $ dst=fubar
  $ src=$PWD/snafu

  $ cat > $rules <<EOF
  > mtc_create_script $dst $src
  > EOF


rejects /source
***************

  $ motoconf $rules
  motoconf: /*/snafu: rejected (glob)
  [1]

  $ ! test -e $dst
  $ ! test -e $src


  $ echo @srcdir@ > $src

  $ motoconf $rules
  motoconf: /*/snafu: rejected (glob)
  [1]

  $ ! test -e $dst
