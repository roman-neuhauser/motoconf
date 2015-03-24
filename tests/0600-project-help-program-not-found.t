registered program not found, project help requested
====================================================

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

  $ cat >moto.conf <<EOF
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

  $ motoconf moto.conf --help
  motoconf: unlikely1: file not found (glob)
  motoconf: unlikely2: file not found (glob)
  
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
    _1ST              =  
    _2ND              =  
  [1]
  $ test -e file
  [1]

::

  $ touch unlikely1
  $ chmod u+x unlikely1
  $ PATH=$PATH:$PWD
  $ rm -f file

::

  $ motoconf moto.conf --help
  motoconf: unlikely2: file not found (glob)
  
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
    _1ST              =  */unlikely1 (glob)
    _2ND              =  
  [1]
  $ test -e file
  [1]
