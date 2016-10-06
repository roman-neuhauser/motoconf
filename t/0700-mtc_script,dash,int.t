mtc_create_script
=================

setup
*****

::

  $ . $TESTDIR/setup

  $ rules=moto.rules

  $ dst=fubar
  $ src=-

  $ cat > $rules <<EOF
  > echo echo @srcdir@ |
  > mtc_create_script $dst $src
  > EOF


"-" for source denotes stdin
****************************

  $ motoconf $rules

  $ ! test -e $src
  $ test -x $dst
  $ cat $dst
  echo .
