registered program not found
============================

setup
*****

::

  $ . $TESTDIR/setup

  $ cat >file.in <<'EOF'
  > PATH=@PATH@
  > prefix=@prefix@
  > srcdir=@srcdir@
  > BASE=@BASE@
  > FULL=@FULL@
  > EOF

test
****

::

  $ rm -f file
  $ cat >moto.conf <<'EOF'
  > mtc_register \
  >   -- program BASE unlikely \
  >   -- program FULL /un/li/ke/ly
  > mtc_populate file
  > EOF
  $ motoconf moto.conf
  motoconf: unlikely: file not found
  [1]
  $ test -e file
  [1]

::

  $ rm -f file
  $ cat >moto.conf <<'EOF'
  > mtc_register \
  >   -- program FULL /un/li/ke/ly \
  >   -- program BASE unlikely
  > mtc_populate file
  > EOF
  $ motoconf moto.conf
  motoconf: /un/li/ke/ly: file not found
  [1]
  $ test -e file
  [1]
