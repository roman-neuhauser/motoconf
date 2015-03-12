display project-specific help
=============================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ touch foo bar
  $ chmod u+x foo bar

  $ cat >moto.conf <<'EOF'
  > mtc_register \
  >   -- program ROFL foo bar \
  >   -- program LMAO bar foo \
  >   -- string OPTS --omg --wtf
  > mtc_populate file
  > EOF
  $ cat >file.in <<'EOF'
  > PATH=@PATH@
  > prefix=@prefix@
  > srcdir=@srcdir@
  > ROFL=@ROFL@
  > LMAO=@LMAO@
  > OPTS=@OPTS@
  > EOF

  $ PATH=$PWD:$PATH
  $ motoconf moto.conf --help
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr/local
    srcdir      =  .
    ROFL        =  /*/foo (glob)
    LMAO        =  /*/bar (glob)
    OPTS        =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --help --prefix=/usr
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr
    srcdir      =  .
    ROFL        =  /*/foo (glob)
    LMAO        =  /*/bar (glob)
    OPTS        =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --prefix=/usr --help
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr
    srcdir      =  .
    ROFL        =  /*/foo (glob)
    LMAO        =  /*/bar (glob)
    OPTS        =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --prefix=/usr --help ROFL=true OPTS='--rofl --lmao'
  Supported variables and their current values:
    PATH        =  (?!@PATH@).* (re)
    prefix      =  /usr
    srcdir      =  .
    ROFL        =  true
    LMAO        =  /*/bar (glob)
    OPTS        =  --rofl --lmao
  $ test -e file
  [1]
