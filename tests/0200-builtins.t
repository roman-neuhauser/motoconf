builtin placeholders
====================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ cat >moto.conf <<'EOF'
  > mtc_populate file
  > EOF
  $ cat >file.in <<'EOF'
  > PATH=@PATH@
  > prefix=@prefix@
  > srcdir=@srcdir@
  > EOF

  $ motoconf moto.conf
  $ cat file
  PATH=(?!@PATH@).* (re)
  prefix=/usr/local
  srcdir=.
  $ rm file

  $ motoconf moto.conf --prefix=/usr
  $ cat file
  PATH=(?!@PATH@).* (re)
  prefix=/usr
  srcdir=.
