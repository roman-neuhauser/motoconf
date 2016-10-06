`mtc_register` interface
========================

setup
*****

::

  $ . $TESTDIR/setup

test
****

::

  $ cat >moto.rules <<EOF
  > mtc_register
  > EOF
  $ motoconf moto.rules
  $ test $? -eq 0 # succeeds!

  $ cat >moto.rules <<EOF
  > mtc_register foo
  > EOF
  $ motoconf moto.rules
  motoconf: mtc_register: malformed spec: foo
  [1]

  $ cat >moto.rules <<EOF
  > mtc_register foo bar unlikely
  > EOF
  $ motoconf moto.rules
  motoconf: mtc_register: malformed spec: foo bar unlikely
  [1]

  $ cat >moto.rules <<EOF
  > mtc_register -- foo bar unlikely
  > EOF
  $ motoconf moto.rules
  motoconf: mtc_register: foo: unknown value kind, expected one of: program string
  [1]

  $ cat >moto.rules <<EOF
  > mtc_register \
  >   -- omg wtf unlikely \
  >   -- foo bar unlikely
  > EOF
  $ motoconf moto.rules
  motoconf: mtc_register: omg: unknown value kind, expected one of: program string
  [1]

  $ cat >moto.rules <<EOF
  > mtc_register \
  >   -- string wtf unlikely \
  >   -- string bar
  > EOF
  $ motoconf moto.rules
  motoconf: mtc_register: incomplete spec: -- string bar
  [1]
