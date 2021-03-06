motoconf help
=============

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ motoconf -h
  motoconf: usage: motoconf -h | --help
  motoconf: usage: motoconf -c INPUT
  motoconf: usage: motoconf INPUT [--prefix=PFX] [NAME=VALUE...]

  $ cat >man <<'EOF'
  > #!/bin/sh
  > printf "${0##*/}"
  > printf " '%s'" "$@"
  > printf "\n"
  > EOF
  $ chmod u+x man
  $ PATH=$PWD:$PATH motoconf --help
  man 'motoconf'
