#!/bin/sh
# vim: noet sts=2 sw=2 ts=8 fdm=marker cms=\ #\ %s

set -eu

_SELF=${0##*/}

mtc_register_values() # {{{
{
  while [ $# -gt 2 ]; do
    mtc_register_$1 "$2" "$3"
    shift 3
  done

  if [ $want_help -ne 0 ]; then # {{{
    printf "Supported variables and their current values:\n"
    local val
    for var in $variables; do
      eval "printf '  %-10s  =  %s\n' $var \"\$$var\""
    done
  fi # }}}

  local prog
  for prog in $programs; do
    mtc_check_program $prog
  done

  if [ $want_help -ne 0 ]; then # {{{
    exit
  fi # }}}
} # }}}

mtc_register_string() # {{{
{
  local var="${1?}" default="${2?}"
  eval ": \${$var=\"$default\"}"
  variables="$variables $var"
} # }}}
mtc_register_program() # {{{
{
  local var="${1?}" default="${2?}"
  mtc_register_string "$var" "$default"
  programs="$programs $var"
} # }}}

mtc_first_in_path() # {{{
{
  local pth
  local dir prog
  for prog do
    pth="$PATH"
    while :; do
      dir="${pth%%:*}"
      pth="${pth#*:}"
      dex="$dir/$prog"
      if [ -f "$dex" -a -x "$dex" ]; then
        printf "%s" "$dex"
        return
      fi
      if [ "$dir" = "$pth" ]; then
        break
      fi
    done
  done
  return 1
} # }}}
mtc_check_program() # {{{
{
  _mtc_chatty -v _mtc_do_check_program "$@"
} # }}}
_mtc_do_check_program() # {{{
{
  local var="$1"
  eval "local prog=\"\$$var\""
  printf "checking %-16s" "$var ..."
  case "$prog" in
  /*)
    if [ -f "$prog" -a -x "$prog" ]; then
      printf "%s\n" "$prog"
    else
      printf "FAIL\n"
      _mtc_errormsg "%s: not runnable\n" "$prog"
      exit 1
    fi
    ;;
  *)
    if mtc_first_in_path "$prog"; then
      printf "\n"
    else
      printf "FAIL\n"
      _mtc_errormsg "%s: file not found\n" "$prog"
      exit 1
    fi
    ;;
  esac
} # }}}
mtc_create_script() # {{{
{
  local file=${1:?}
  _mtc_chatty -vv printf "generating %s\n" "$1"
  cat > $file.in
  _mtc_chatty -vvv mtc_populate $file
  chmod +x $file
  rm $file.in
} # }}}
mtc_populate() # {{{
{
  local file="${1?}" val="" seds=""
  _mtc_chatty -v printf "populating %s\n" "$file"
  local input="$srcdir/$file.in"
  if [ -e "$file.in" ]; then
    input="$file.in"
  fi
  for var in $variables; do
    eval "val=\"\$$var\""
    seds="$seds s@$var@$valg;"
  done
  sed "$seds" < "$input" > "$file"
} # }}}
_mtc_chatty() # {{{
{
  local v=${1#-}
  shift
  if [ ${#v} -le $verbosity ]; then
    "$@"
  else
    "$@" > /dev/null
  fi
} # }}}
_mtc_errormsg() # {{{
{
  printf >&2 "%s: " "$_SELF"
  printf >&2 "$@"
} # }}}
_mtc_help() # {{{
{
  man "$_SELF"
  exit
} # }}}
_mtc_usage() # {{{
{
  _mtc_errormsg "usage: %s -h | --help\n" "$_SELF"
  _mtc_errormsg "usage: %s -c INPUT\n" "$_SELF"
  _mtc_errormsg "usage: %s INPUT [--prefix=PFX] [NAME=VALUE...]\n" "$_SELF"
  exit ${1:-111}
} # }}}

_mtc_create_configure() # {{{
{
  cat >configure <<-EOF
	#!/bin/sh
	cfg="$1"
	dir="\$(dirname "\$0")"
	exec motoconf "\$dir/\$cfg" "\$@"
EOF
  chmod +x configure
} # }}}

want_help=0
want_configure=0
verbosity=0
prefix=/usr/local

# process arguments {{{
if [ "x${1+set}" != xset ]; then
  _mtc_usage 1
else
  case "$1" in
  -c)
    if [ $# -ne 2 ] || ! [ -f "$2" ]; then
      _mtc_errormsg "the '-c' option requires an INPUT script\n"
      _mtc_usage 1
    else
      want_configure=1
      shift
    fi
  ;;
  -h)
    _mtc_usage 0
  ;;
  --help)
    _mtc_help
  ;;
  esac
fi

if [ $# -gt 0 ]; then
  script="${1:-}"; shift

  [ -e "$script" ] || {
    _mtc_errormsg "%s: file not found\n" "$script"
    exit 1
  }

  if [ $want_configure -ne 0 ]; then
    _mtc_create_configure "$script"
    exit
  fi

  while [ $# -gt 0 ]; do # {{{
    case "$1" in
    -h)
      _mtc_usage 0
      ;;
    -h|--help)
      want_help=1
      ;;
    -v|--verbose)
      verbosity=$(( verbosity + 1 ))
      ;;
    --prefix=*)
      prefix="${1#--prefix=}"
      ;;
    --prefix)
      shift
      prefix="${1:?}"
      ;;
    -*)
      _mtc_errormsg "unknown option: %s\n" "$1"
      _mtc_usage 1
      ;;
    *=*)
      var="${1%%=*}" val="${1#*=}"
      eval "$var=\"\$val\""
      ;;
    esac
    shift
  done # }}}
fi
# }}}

srcdir="$(dirname $script)"

variables="PATH prefix srcdir"
programs=""

# ================================================

case $script in
*/*) ;;
*) script="./$script" ;;
esac

. "$script"
