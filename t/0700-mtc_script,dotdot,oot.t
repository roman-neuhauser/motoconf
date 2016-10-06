mtc_create_script
=================

setup
*****

::

  $ . $TESTDIR/setup

  $ mkdir foo bar

  $ srcdir=../foo
  $ rules=$srcdir/moto.rules

  $ dst=fubar
  $ src=../snafu

  $ cat > ${rules#../} <<EOF
  > mtc_create_script $dst $src
  > EOF


rejects ../source
*****************

  $ cd bar

  $ motoconf $rules
  motoconf: ../snafu: rejected
  [1]

  $ ! test -e $dst
  $ ! test -e $src


  $ echo @srcdir@ > $src

  $ motoconf $rules
  motoconf: ../snafu: rejected
  [1]

  $ ! test -e $dst
