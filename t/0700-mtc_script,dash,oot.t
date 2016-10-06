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
  $ src=-

  $ cat > ${rules#../} <<EOF
  > echo echo @srcdir@ |
  > mtc_create_script $dst $src
  > EOF


"-" for source denotes stdin
****************************

  $ cd bar

  $ motoconf $rules

  $ ! test -e $src
  $ test -x $dst
  $ cat $dst
  echo ../foo
