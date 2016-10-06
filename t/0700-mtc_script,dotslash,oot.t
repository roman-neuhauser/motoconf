mtc_create_script
=================

setup
*****

::

  $ . $TESTDIR/setup

  $ mkdir foo bar

  $ rules=../foo/moto.rules

  $ dst=fubar
  $ src=./snafu

  $ cat > ${rules#../} <<EOF
  > mtc_create_script $dst $src
  > EOF


./source is relative to builddir
********************************

  $ cd bar

  $ motoconf $rules
  motoconf: ./snafu: file not found
  [1]

  $ ! test -e $dst
  $ ! test -e $src


  $ echo @srcdir@ > $src

  $ motoconf $rules
  $ cat $dst
  ../foo
