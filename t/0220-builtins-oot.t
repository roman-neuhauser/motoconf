builtin placeholders, out-of-tree
=================================

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

  $ mkdir build
  $ cd build

  $ motoconf ../moto.conf
  populating file
  $ cat file
  PATH=(?!@PATH@).* (re)
  prefix=/usr/local
  srcdir=..
  $ rm file

  $ motoconf ../moto.conf --prefix=/usr
  populating file
  $ cat file
  PATH=(?!@PATH@).* (re)
  prefix=/usr
  srcdir=..
