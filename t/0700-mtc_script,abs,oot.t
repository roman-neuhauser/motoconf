mtc_create_script
=================

setup
*****

::

  $ . $TESTDIR/setup

  $ mkdir foo bar

  $ rules=../foo/moto.rules
  $ srcdir=../foo

  $ dst=fubar
  $ src=$PWD/snafu

  $ cat > ${rules#../} <<EOF
  > mtc_create_script $dst $src
  > EOF


rejects /source
***************

  $ cd bar

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
