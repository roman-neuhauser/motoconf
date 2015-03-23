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
  > _1ST=@BASE@
  > _2ND=@FULL@
  > EOF

  $ cat >moto.conf <<'EOF'
  > mtc_register \
  >   -- program _1ST unlikely1 \
  >   -- program _2ND unlikely2
  > mtc_populate file
  > EOF

test
****

::

  $ rm -f file

::

  $ motoconf moto.conf
  motoconf: unlikely1: file not found
  [1]
  $ test -e file
  [1]

::

  $ touch unlikely1
  $ chmod u+x unlikely1
  $ PATH=$PATH:$PWD
  $ rm -f file

::

  $ motoconf moto.conf
  motoconf: unlikely2: file not found
  [1]
  $ test -e file
  [1]
