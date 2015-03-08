create configure, moto linked
=============================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ cat >moto.conf <<'EOF'
  > register_values \
  >   program  TEST  true \
  >   string   OPTS  "--rofl --lmao"
  > populate file
  > EOF

  $ test -e configure
  [1]
  $ motoconf -c
  motoconf: the '-c' option requires an INPUT script
  motoconf: usage: motoconf -h | --help
  motoconf: usage: motoconf -c INPUT
  motoconf: usage: motoconf INPUT [--prefix=PFX] [NAME=VALUE...]
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
    TEST        =  true
    OPTS        =  --rofl --lmao

