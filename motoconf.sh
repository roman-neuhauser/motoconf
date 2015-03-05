#!/bin/sh
# vim: noet sts=2 sw=2 ts=8 fdm=marker cms=\ #\ %s

set -eu

_SELF=${0##*/}

register_values() # {{{
{
  while (( $# > 2 )); do
    register_$1 "$2" "$3"
    shift 3
  done

  if (( want_help )); then # {{{
    printf "Supported variables and their current values:\n"
    local val
    for var in $variables; do
      eval "printf '  %-10s  =  %s\n' $var \"\$$var\""
    done
  fi # }}}

  local prog
  for prog in $programs; do
    check_program $prog
  done

  if (( want_help )); then # {{{
    exit
  fi # }}}
} # }}}

register_string() # {{{
{
  local var="${1?}" default="${2?}"
  eval ": \${$var=\"$default\"}"
  variables="$variables $var"
} # }}}
register_program() # {{{
{
  local var="${1?}" default="${2?}"
  register_string "$var" "$default"
  programs="$programs $var"
} # }}}

first_in_path() # {{{
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
check_program() # {{{
{
  chatty -v do_check_program "$@"
} # }}}
do_check_program() # {{{
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
      errormsg "%s: not runnable\n" "$prog"
      exit 1
    fi
    ;;
  *)
    if first_in_path "$prog"; then
      printf "\n"
    else
      printf "FAIL\n"
      errormsg "%s: file not found\n" "$prog"
      exit 1
    fi
    ;;
  esac
} # }}}
create_script() # {{{
{
  local file=${1:?}
  chatty -vv printf "generating %s\n" "$1"
  cat > $file.in
  chatty -vvv populate $file
  chmod +x $file
  rm $file.in
} # }}}
populate() # {{{
{
  local file="${1?}" val="" seds=""
  chatty -v printf "populating %s\n" "$file"
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
chatty() # {{{
{
  local v=${1#-}
  shift
  if (( ${#v} <= verbosity )); then
    "$@"
  else
    "$@" > /dev/null
  fi
} # }}}
errormsg() # {{{
{
  printf >&2 "%s: " "$_SELF"
  printf >&2 "$@"
} # }}}

create_configure() # {{{
{
  cat >configure <<-EOF
	#!/bin/sh
	cfg="$1"
	dir="\$(dirname "\$0")"
	exec motoconf "\$dir/\$cfg" "\$@"
EOF
  chmod +x configure
} # }}}

exit_code=0
want_help=0
want_man=0
want_usage=0
want_configure=0
verbosity=0
prefix=/usr/local

# process arguments {{{
case "$1" in
-c)
  if (( $# == 2 )) && [ -f "$2" ]; then
    want_configure=1
    shift
  else
    errormsg "the '-c' option requires an INPUT script\n" "$_SELF"
    want_usage=1
  fi
;;
-h) want_usage=1 ;;
--help) want_man=1 ;;
esac

if (( 0 == want_usage && 0 == want_man )); then
  script="$1"; shift

  test -e "$script" || {
    errormsg "%s: file not found\n" "$script"
    exit 1
  }

  if (( want_configure )); then
    create_configure "$script"
    exit
  fi

  while (( $# )); do # {{{
    case "$1" in
    -h)
      want_usage=1
      ;;
    -h|--help)
      want_help=1
      ;;
    -v|--verbose)
      (( verbosity += 1 ))
      ;;
    --prefix=*)
      prefix="${1#--prefix=}"
      ;;
    --prefix)
      shift
      prefix="${1:?}"
      ;;
    -*)
      errormsg "unknown option: %s\n" "$1"
      want_usage=1
      exit_code=1
      break
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

if (( want_usage )); then # {{{
  errormsg "usage: %s [-h|--help]\n" "$_SELF"
  errormsg "usage: %s -c INPUT\n" "$_SELF"
  errormsg "usage: %s INPUT [--prefix=PFX] [NAME=VALUE...]\n" "$_SELF"
  exit $exit_code
fi # }}}
if (( want_man )); then # {{{
  man "$_SELF"
  exit
fi # }}}

srcdir="$(dirname $script)"

variables="PATH prefix srcdir"
programs=""

# ================================================

case $script in
*/*) ;;
*) script="./$script" ;;
esac

. "$script"
