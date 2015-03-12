create configure, moto linked
=============================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ touch foo
  $ chmod u+x foo
  $ PATH="$PWD:$PATH"
  $ cat >moto.conf <<'EOF'
  > mtc_register \
  >   -- program  ROFL  foo \
  >   -- string   OPTS  --rofl --lmao
  > mtc_populate file
  > EOF

  $ test -e configure
  [1]
  $ motoconf -c
  motoconf: the '-c' option requires an INPUT script
  motoconf: usage: motoconf -h | --help
  motoconf: usage: motoconf -c INPUT
  motoconf: usage: motoconf INPUT [--prefix=PFX] [NAME=VALUE...]
  [1]
  $ test -e configure
  [1]
  $ motoconf -c moto.conf
  $ test -e configure
  $ test -x configure
  $ ./configure --help
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr/local
    srcdir      =  .
    ROFL        =  /*/foo (glob)
    OPTS        =  --rofl --lmao

