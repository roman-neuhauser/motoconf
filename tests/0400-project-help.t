display project-specific help
=============================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ cat >moto.conf <<'EOF'
  > register_values program TEST true string OPTS "--omg --wtf"
  > populate file
  > EOF
  $ cat >file.in <<'EOF'
  > PATH=@PATH@
  > prefix=@prefix@
  > srcdir=@srcdir@
  > TEST=@TEST@
  > OPTS=@OPTS@
  > EOF

  $ motoconf moto.conf --help
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr/local
    srcdir      =  .
    TEST        =  true
    OPTS        =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --help --prefix=/usr
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr
    srcdir      =  .
    TEST        =  true
    OPTS        =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --prefix=/usr --help
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr
    srcdir      =  .
    TEST        =  true
    OPTS        =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --prefix=/usr --help TEST=false OPTS='--rofl --lmao'
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr
    srcdir      =  .
    TEST        =  false
    OPTS        =  --rofl --lmao
  $ test -e file
  [1]
