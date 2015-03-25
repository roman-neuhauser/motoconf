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
  checking ROFL ... */foo (glob)
  
  Supported variables and their current values:
    PATH              =  * (glob)
    srcdir            =  .
    prefix            =  /usr/local
    exec_prefix       =  /usr/local
    bindir            =  /usr/local/bin
    sbindir           =  /usr/local/sbin
    libexecdir        =  /usr/local/libexec
    datarootdir       =  /usr/local/share
    datadir           =  /usr/local/share
    sysconfdir        =  /usr/local/etc
    sharedstatedir    =  /usr/local/com
    localstatedir     =  /usr/local/var
    includedir        =  /usr/local/include
    docdir            =  /usr/local/share/doc
    infodir           =  /usr/local/share/info
    htmldir           =  /usr/local/share/doc
    dvidir            =  /usr/local/share/doc
    pdfdir            =  /usr/local/share/doc
    psdir             =  /usr/local/share/doc
    libdir            =  /usr/local/lib
    localedir         =  /usr/local/share/locale
    mandir            =  /usr/local/share/man
    program_prefix    =  
    program_suffix    =  
    ROFL              =  */foo (glob)
    OPTS              =  --rofl --lmao

