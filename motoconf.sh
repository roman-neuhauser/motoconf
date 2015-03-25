#!@SHEBANG@
# vim: noet sts=2 sw=2 ts=8 fdm=marker cms=\ #\ %s

set -eu

_SELF=${0##*/}

mtc_register() # {{{
{
  local kind i
  local kinds="program string"
  while [ $# -gt 3 ]; do
    if [ "x$1" != x-- ]; then
      _mtc_errormsg "mtc_register: expected '--' got '%s'\n" "$1"
      exit 1
    fi
    kind="$2"
    shift 2
    case $kinds in
    *$kind*) ;;
    *)
      _mtc_errormsg "mtc_register: %s: unknown value kind, expected one of: %s\n" \
	"$kind" \
	"$kinds"
      return 1
    ;;
    esac
    mtc_register_$kind "$@"
    i=0
    _mtc_find_delim "$@" || i=$?
    if [ $i -eq 0 ]; then
      shift $#
      break
    fi
    shift $(( i - 1 ))
  done
  if [ $# -ne 0 ]; then
    if [ "x$1" = x-- ]; then
      _mtc_errormsg "mtc_register: incomplete spec: %s\n" "$*"
    else
      _mtc_errormsg "mtc_register: malformed spec: %s\n" "$*"
    fi
    return 1
  fi
  _mtc_handle_inputs
} # }}}
_mtc_handle_inputs() # {{{
{
  local failed=0 prog

  for prog in $_mtc_programs; do # {{{
    if ! mtc_check_program $prog; then
      failed=1
    fi
  done # }}}

  if [ $_mtc_project_help_wanted -ne 0 ]; then # {{{
    if [ $failed -ne 0 ] || [ $_mtc_verbosity -gt 0 ]; then
      printf "\n"
    fi
    printf "Supported variables and their current values:\n"
    local val var
    for var in $_mtc_variables; do
      eval "val=\"\$$var\""
      printf '  %-16s  =  %s\n' "$var" "$val"
    done
  fi # }}}

  if [ $failed -ne 0 ]; then # {{{
    exit $failed
  fi # }}}

  if [ $_mtc_project_help_wanted -ne 0 ]; then # {{{
    exit
  fi # }}}
} # }}}
mtc_register_string() # {{{
{
  local val= var="$1"
  shift
  for arg; do
    if [ "x$arg" = x-- ]; then
      break
    fi
    if [ -z "$val" ]; then
      val="$arg"
    else
      val="$val $arg"
    fi
  done
  eval ": \${$var=\"\$val\"}"
  _mtc_variables="$_mtc_variables $var"
} # }}}
mtc_register_program() # {{{
{
  local prog var="$1"
  shift
  mtc_register_string "$var" "$@"
  _mtc_programs="$_mtc_programs $var"
} # }}}
_mtc_find_delim() # {{{
{
  local i=0
  for arg; do
    i=$(( i + 1 ))
    if [ "x$arg" = x-- ]; then
      return $i
    fi
  done
  return 0
} # }}}

mtc_first_in_path() # {{{
{
  local prog
  for prog; do
    if [ "x$prog" = x-- ]; then
      break
    fi
    if _mtc_find_prog "$prog"; then
      return
    fi
  done
  return 1
} # }}}
_mtc_program_not_found() # {{{
{
  local prog var="$1"; shift
  for prog; do
    if [ "x$prog" = x-- ]; then
      break
    fi
    if [ -e "$prog" ]; then
      _mtc_errormsg "%s: %s: not runnable\n" "$var" "$prog"
    else
      _mtc_errormsg "%s: %s: file not found\n" "$var" "$prog"
    fi
  done
} # }}}
_mtc_find_prog() # {{{
{
  local dex dir prog="$1" pth="$PATH"
  case $prog in
  /*)
    if [ -f "$prog" -a -x "$prog" ]; then
      printf "%s" "$prog"
      return
    fi
  ;;
  esac
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
  return 1
} # }}}
mtc_check_program() # {{{
{
  _mtc_chatty -v _mtc_do_check_program "$@"
} # }}}
_mtc_do_check_program() # {{{
{
  local prog result var="$1"
  local banner="checking %s ... "
  local banlen=$((${#banner} + ${#var} - 2))
  local vallen=$((${COLUMNS:-80} - banlen))
  local valfmt="%${vallen}s\n"
  eval "prog=\"\$$var\""
  printf "$banner" "$var"
  if result="$(mtc_first_in_path $prog)"; then
    eval "$var=\"\$result\""
    printf "$valfmt" "$result"
  else
    printf "$valfmt" FAIL
    _mtc_program_not_found $var $prog
    eval "$var="
    return 1
  fi
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
_mtc_verbosity=1
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
  -v|--verbose)
    _mtc_verbosity=$(( _mtc_verbosity + 1 ))
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
  --prefix=*) prefix="${1#*=}" ;;
  --prefix) shift; prefix="$1" ;;

  --exec-prefix=*) exec_prefix="${1#*=}" ;;
  --exec-prefix) shift; exec_prefix="$1" ;;

  --bindir=*) bindir="${1#*=}" ;;
  --bindir) shift; bindir="$1" ;;

  --sbindir=*) sbindir="${1#*=}" ;;
  --sbindir) shift; sbindir="$1" ;;

  --libexecdir=*) libexecdir="${1#*=}" ;;
  --libexecdir) shift; libexecdir="$1" ;;

  --sysconfdir=*) sysconfdir="${1#*=}" ;;
  --sysconfdir) shift; sysconfdir="$1" ;;

  --sharedstatedir=*) sharedstatedir="${1#*=}" ;;
  --sharedstatedir) shift; sharedstatedir="$1" ;;

  --localstatedir=*) localstatedir="${1#*=}" ;;
  --localstatedir) shift; localstatedir="$1" ;;

  --libdir=*) libdir="${1#*=}" ;;
  --libdir) shift; libdir="$1" ;;

  --includedir=*) includedir="${1#*=}" ;;
  --includedir) shift; includedir="$1" ;;

  --datadir=*) datadir="${1#*=}" ;;
  --datadir) shift; datadir="$1" ;;

  --mandir=*) mandir="${1#*=}" ;;
  --mandir) shift; mandir="$1" ;;

  --program-prefix=*) program_prefix="${1#*=}" ;;
  --program-prefix) shift; program_prefix="$1" ;;

  --program-suffix=*) program_suffix="${1#*=}" ;;
  --program-suffix) shift; program_suffix="$1" ;;

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

srcdir="$(dirname "$mtc_input")"
# }}}

# assign --whateverdir paths {{{
: ${exec_prefix:=$prefix}
: ${bindir:=${exec_prefix}/bin}
: ${sbindir:=${exec_prefix}/sbin}
: ${libexecdir:=${exec_prefix}/libexec}
: ${datarootdir:=${prefix}/share}
: ${datadir:=${datarootdir}}
if [ "x${prefix}" = x/usr ]; then
  : ${sysconfdir:=/etc}
else
  : ${sysconfdir:=${prefix}/etc}
fi
: ${sharedstatedir:=$prefix/com}
if [ "x${prefix}" = x/usr ]; then
  : ${localstatedir:=/var}
else
  : ${localstatedir:=${prefix}/var}
fi
: ${includedir:=$prefix/include}
: ${docdir:=$datarootdir/doc}
: ${infodir:=$datarootdir/info}
: ${htmldir:=$docdir}
: ${dvidir:=$docdir}
: ${pdfdir:=$docdir}
: ${psdir:=$docdir}
: ${libdir:=$exec_prefix/lib}
: ${localedir:=$datarootdir/locale}
: ${mandir:=$datarootdir/man}

: ${program_prefix:=}
: ${program_suffix:=}
# }}}

# substitutions {{{
_mtc_variables="
  PATH
  srcdir

  prefix
  exec_prefix
  bindir
  sbindir
  libexecdir
  datarootdir
  datadir
  sysconfdir
  sharedstatedir
  localstatedir
  includedir
  docdir
  infodir
  htmldir
  dvidir
  pdfdir
  psdir
  libdir
  localedir
  mandir

  program_prefix
  program_suffix
"
_mtc_programs=""
# }}}

# ================================================

case "$mtc_input" in
*/*) ;;
*) mtc_input="./$mtc_input" ;;
esac

. "$mtc_input"
