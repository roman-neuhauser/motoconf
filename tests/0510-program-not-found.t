registered program not found, part 2
====================================

setup
*****

::

  $ . $TESTDIR/setup

  $ cat >file.in <<'EOF'
  > MEH=@MEH@
  > EOF

test
****

::

  $ rm -f file
  $ cat >moto.conf <<'EOF'
  > mtc_register -- program MEH unlikely
  > mtc_populate file
  > EOF
  $ motoconf moto.conf
  checking MEH ...         FAIL
  motoconf: MEH: unlikely: file not found
  [1]
  $ test -e file
  [1]

::

  $ rm -f file
  $ cat >moto.conf <<'EOF'
  > mtc_register -- program MEH unlikely1 unlikely2
  > mtc_populate file
  > EOF
  $ motoconf moto.conf
  checking MEH ...         FAIL
  motoconf: MEH: unlikely1: file not found
  motoconf: MEH: unlikely2: file not found
  [1]
  $ test -e file
  [1]

::

  $ touch unlikely2
  $ chmod u+x unlikely2
  $ PATH=$PATH:$PWD
  $ rm -f file
  $ cat >moto.conf <<'EOF'
  > mtc_register -- program MEH unlikely1 unlikely2 unlikely3
  > mtc_populate file
  > EOF
  $ motoconf moto.conf
  checking MEH ...         */unlikely2 (glob)
  populating file
  $ cat file
  MEH=/*/unlikely2 (glob)
