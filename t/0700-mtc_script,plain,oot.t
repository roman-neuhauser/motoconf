mtc_create_script
=================

setup
*****

::

  $ . $TESTDIR/setup

  $ mkdir foo bar qux

  $ rules=../foo/moto.rules
  $ srcdir=../foo

  $ dst=fubar
  $ src=snafu

  $ cat > ${rules#../} <<EOF
  > mtc_create_script $dst $src
  > EOF


source is relative to $rootdir
******************************

  $ cd bar

  $ motoconf $rules
  motoconf: ../foo/snafu: file not found
  [1]

  $ ! test -e $dst
  $ ! test -e $src


  $ cd $srcdir

  $ echo @srcdir@ > $src

  $ cd -

  $ motoconf $rules
  $ cat $dst
  ../foo
