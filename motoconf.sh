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

  if [ $_mtc_project_help_wanted -ne 0 ]; then # {{{
    printf "Supported variables and their current values:\n"
    local val var
    for var in $_mtc_variables; do
      eval "val=\"\$$var\""
      printf '  %-10s  =  %s\n' "$var" "$val"
    done
  fi # }}}

  local prog
  for prog in $_mtc_programs; do
    mtc_check_program $prog
  done

  if [ $_mtc_project_help_wanted -ne 0 ]; then # {{{
    exit
  fi # }}}
} # }}}

mtc_register_string() # {{{
{
  local var="$1" default="$2"
  eval ": \${$var=\"\$default\"}"
  _mtc_variables="$_mtc_variables $var"
} # }}}
mtc_register_program() # {{{
{
  local var="$1" default="$2"
  mtc_register_string "$var" "$default"
  _mtc_programs="$_mtc_programs $var"
} # }}}

mtc_first_in_path() # {{{
{
  local dex dir prog pth
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
  local prog var="$1"
  eval "prog=\"\$$var\""
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
  local file="$1"
  _mtc_chatty -vv printf "generating %s\n" "$file"
  cat > "$file.in"
  _mtc_chatty -vvv mtc_populate "$file"
  chmod +x "$file"
  rm "$file.in"
} # }}}
mtc_populate() # {{{
{
  local file="$1" seds=""
  _mtc_chatty -v printf "populating %s\n" "$file"
  local input="$srcdir/$file.in"
  if [ -e "$file.in" ]; then
    input="$file.in"
  fi
  local val var
  for var in $_mtc_variables; do
    eval "val=\"\$$var\""
    seds="$seds s@$var@$valg;"
  done
  sed "$seds" < "$input" > "$file"
} # }}}
_mtc_chatty() # {{{
{
  local v=${1#-}
  shift
  if [ ${#v} -le $_mtc_verbosity ]; then
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
_mtc_assert_file() # {{{
{
  [ -f "$1" ] || {
    _mtc_errormsg "%s: file not found\n" "$1"
    exit 1
  }
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

_mtc_project_help_wanted=0
_mtc_verbosity=0
prefix=/usr/local

# process arguments {{{
if [ $# -eq 0 ]; then
  _mtc_usage 1
fi

while [ $# -gt 0 ]; do # motoconf options {{{
  case "$1" in
  -c)
    shift
    if [ $# -lt 1 ]; then
      _mtc_errormsg "the '-c' option requires an INPUT script\n"
      _mtc_usage 1
    else
      _mtc_assert_file "$1"
      _mtc_create_configure "$1"
      exit
    fi
  ;;
  -h)
    _mtc_usage 0
  ;;
  --help)
    _mtc_help
  ;;
  -*)
    _mtc_errormsg "unknown option: %s\n" "$1"
    _mtc_usage 1
  ;;
  *)
    # not an option, should be the INPUT script
    break
  ;;
  esac
  shift
done # }}}

if [ $# -eq 0 ]; then
  _mtc_usage 1
fi

mtc_input="$1"; shift
_mtc_assert_file "$mtc_input"

while [ $# -gt 0 ]; do # project-specific stuff {{{
  case "$1" in
  -h)
    _mtc_usage 0
    ;;
  -h|--help)
    _mtc_project_help_wanted=1
    ;;
  -v|--verbose)
    _mtc_verbosity=$(( _mtc_verbosity + 1 ))
    ;;
  --prefix=*)
    prefix="${1#--prefix=}"
    ;;
  --prefix)
    shift
    prefix="$1"
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
# }}}

srcdir="$(dirname "$mtc_input")"

_mtc_variables="PATH prefix srcdir"
_mtc_programs=""

# ================================================

case "$mtc_input" in
*/*) ;;
*) mtc_input="./$mtc_input" ;;
esac

. "$mtc_input"
