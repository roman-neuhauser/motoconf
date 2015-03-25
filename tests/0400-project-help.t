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
  checking ROFL ...        */foo (glob)
  checking LMAO ...        */bar (glob)
  
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
    LMAO              =  */bar (glob)
    OPTS              =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --help --prefix=/usr
  checking ROFL ...        */foo (glob)
  checking LMAO ...        */bar (glob)
  
  Supported variables and their current values:
    PATH              =  * (glob)
    srcdir            =  .
    prefix            =  /usr
    exec_prefix       =  /usr
    bindir            =  /usr/bin
    sbindir           =  /usr/sbin
    libexecdir        =  /usr/libexec
    datarootdir       =  /usr/share
    datadir           =  /usr/share
    sysconfdir        =  /etc
    sharedstatedir    =  /usr/com
    localstatedir     =  /var
    includedir        =  /usr/include
    docdir            =  /usr/share/doc
    infodir           =  /usr/share/info
    htmldir           =  /usr/share/doc
    dvidir            =  /usr/share/doc
    pdfdir            =  /usr/share/doc
    psdir             =  /usr/share/doc
    libdir            =  /usr/lib
    localedir         =  /usr/share/locale
    mandir            =  /usr/share/man
    program_prefix    =  
    program_suffix    =  
    ROFL              =  */foo (glob)
    LMAO              =  */bar (glob)
    OPTS              =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --prefix=/usr --help
  checking ROFL ...        */foo (glob)
  checking LMAO ...        */bar (glob)
  
  Supported variables and their current values:
    PATH              =  * (glob)
    srcdir            =  .
    prefix            =  /usr
    exec_prefix       =  /usr
    bindir            =  /usr/bin
    sbindir           =  /usr/sbin
    libexecdir        =  /usr/libexec
    datarootdir       =  /usr/share
    datadir           =  /usr/share
    sysconfdir        =  /etc
    sharedstatedir    =  /usr/com
    localstatedir     =  /var
    includedir        =  /usr/include
    docdir            =  /usr/share/doc
    infodir           =  /usr/share/info
    htmldir           =  /usr/share/doc
    dvidir            =  /usr/share/doc
    pdfdir            =  /usr/share/doc
    psdir             =  /usr/share/doc
    libdir            =  /usr/lib
    localedir         =  /usr/share/locale
    mandir            =  /usr/share/man
    program_prefix    =  
    program_suffix    =  
    ROFL              =  */foo (glob)
    LMAO              =  */bar (glob)
    OPTS              =  --omg --wtf
  $ test -e file
  [1]

  $ motoconf moto.conf --prefix=/usr --help ROFL=true OPTS='--rofl --lmao'
  checking ROFL ...        */true (glob)
  checking LMAO ...        */bar (glob)
  
  Supported variables and their current values:
    PATH              =  * (glob)
    srcdir            =  .
    prefix            =  /usr
    exec_prefix       =  /usr
    bindir            =  /usr/bin
    sbindir           =  /usr/sbin
    libexecdir        =  /usr/libexec
    datarootdir       =  /usr/share
    datadir           =  /usr/share
    sysconfdir        =  /etc
    sharedstatedir    =  /usr/com
    localstatedir     =  /var
    includedir        =  /usr/include
    docdir            =  /usr/share/doc
    infodir           =  /usr/share/info
    htmldir           =  /usr/share/doc
    dvidir            =  /usr/share/doc
    pdfdir            =  /usr/share/doc
    psdir             =  /usr/share/doc
    libdir            =  /usr/lib
    localedir         =  /usr/share/locale
    mandir            =  /usr/share/man
    program_prefix    =  
    program_suffix    =  
    ROFL              =  */true (glob)
    LMAO              =  */bar (glob)
    OPTS              =  --rofl --lmao
  $ test -e file
  [1]
