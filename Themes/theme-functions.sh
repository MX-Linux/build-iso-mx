#!/bin/bash

VERSION=0.02
VERSION_DATE="Tue Nov 26 00:10:26 MST 2013"

MISC_DIR="misc"
COPY_ARGS="--no-dereference --preserve=mode,links"
ME=${0##*/}

do_usage() {
    cat <<Usage
Usage: $ME [options]

Apply a theme to a directory tree by copying and editing files.

Options:
  -b --backup=       Backup edited files with the given extension
  -c --create        Create all target directories as needed
  -C --color=        Set color mode: off|low|high.  Default: high
  -d --dry-run       Don't do anything just say what would be done
  -e --error=        Error mode: ask|ignore|fatal.  Default: ask
  -f --functions     Show function names and arguments
  -h --help          Show this help
  -p --prefix=       Prefix for target directory tree
  -q --quiet         Print less
  -v --version       Print version info and exit
  -V --VERBOSE       Print more

Short options stack

Usage
    exit 0
}

start_theme() {
    read_args "$@"
    set_colors
    [ "$QUIET" ] || report_status
}

report_status() {
    local prefix=${PREFIX:-none}
    say " Theme: $(pq $(basename $THEME_DIR))"
    say "Prefix: $(pq $prefix)"
    local mode="LIVE"
    [ "$DRY_RUN" ] && mode="Dry Run"
    say "  Mode: $(pq $mode)"

    echo
}

do_version() { echo "theme-functions.sh version $VERSION ($VERSION_DATE)";  exit ;}

read_args() {
    local short_stack="bcCdefhpqvV"

    local arg val
    while [ $# -gt 0 -a -z "${1##-*}" ]; do
        arg=${1#-}; shift

        # Unstack single-letter options
        case $arg in
            [$short_stack][$short_stack]*)
                if echo "$arg" | grep -q "^[$short_stack]\+$"; then
                    set -- $(echo $arg | sed -r 's/([a-zA-Z])/ -\1 /g') "$@"
                    continue
                fi;;
        esac

        # Deal with all options that take a parameter
        case $arg in
          -prefix|p|-color|C|-error|e)
            [ $# -lt 1 ] && fatal "Expected a parameter after: $(pqw -$arg)"
            val=$1
            [ -n "$val" -a -z "${val##-*}" ] \
                && fatal "Suspicious argument after -$arg: $(pqw $val)"

            shift ;;

              *=*)  val=${arg#*=} ;;
                *)  val="???"     ;;
        esac

        case $arg in
          -backup|b)      BACKUP=.${val#.}           ;;
      -backup=*|b=*)      BACKUP=.${val#.}           ;;
          -create|c)      CREATE=true                ;;
           -color|C)  COLOR_MODE=$val                ;;
       -color=*|C=*)  COLOR_MODE=$val                ;;
         -dry-run|d)     DRY_RUN=true                ;;
           -error|e)  ERROR_MODE=$val                ;;
       -error=*|e=*)  ERROR_MODE=$val                ;;
       -functions|f)   FUNC_MODE=$val                ;;
            -help|h)    do_usage                     ;;

          -prefix|p)      PREFIX=$val                ;;
       -prefix=*p=*)      PREFIX=$val                ;;
           -quiet|q)       QUIET=true                ;;

         -version|v)    do_version                   ;;

         -VERBOSE|V)     VERBOSE=true                ;;

                  *) fatal "Unknown parameter -$arg" ;;
        esac
    done
}

local_create() {
    local create=$CREATE
    read_my_args "$@"
    [ -n "$create" ] && echo true
}

read_my_args() {
    local arg val
    while [ $# -gt 0 -a -z "${1##-*}" ]; do
        arg=${1#-}; shift

        case $arg in
          -create|c)  create=true  ;;
                  *)  fatal "Unknown argument: -$arg" ;;
        esac
    done
}

require_args() {
    local val nam caller=$1
    shift
    while [ $# -ge 2 ]; do
        val=$1
        nam=$2
        shift 2
        [ -z "$val" ] && fatal "Missing $(pqw $nam) for $caller"
    done
}

copy_file() {
    enter_function copy_file "$@"
    require_args copy_file "$1" "source file" "$2" "target directory"

    local short_src=$MISC_DIR/$1    short_targ=$2
    local      src=$THEME_DIR/$MISC_DIR/$1  targ=$PREFIX${2%/}
    shift 2

    local create=$(local_create "$@")
    [ "$create" ] && echo_run mkdir -p $targ

    [ ! -e $src  ] && error "Could not find theme file: $(pqw $short_src)"   && return
    check_targ_dir $targ $create || return
    echo_run cp $COPY_ARGS $src $targ/
}

copy_dir() {
    enter_function copy_dir "$@"
    require_args copy_dir "$1" "source file" "$2" "target directory"

    local short_src=$1  short_targ=$2
    local       src=$THEME_DIR/${1%/}  targ=$PREFIX${2%/}

    shift 2

    local create=$(local_create "$@")
    [ "$create" ] && echo_run mkdir -p $targ

    [ ! -e $src  ] && error "Could not find theme directory: $(pqw $short_src)" && return
    [ ! -d $src  ] && error "Is not a theme directory: $(pqw $short_src)"       && return
    check_targ_dir $targ $create || return
    echo_run cp --recursive $COPY_ARGS $src/* $targ/
}

escape_regex() { echo "$1" | sed -r 's=([][{}*+?\\().=])=\\\1=g' ;}

enter_function() {
    [ "$FUNC_MODE" ] || return
    local caller=$1
    shift
    yell "$caller$nc $*"
}

append() {
    enter_function append "$@"
    require_args append "$1" "target file"
    local short_targ=$1
    local       targ=$PREFIX$1
    shift 1

    local create=$(local_create "$@")
    [ "$create" ] && echo_run touch $targ

    check_targ_file $targ $create || return

    local line regex found first=true
    for line; do
        regex=$(escape_regex "$line")
        if grep -q "^$regex$" $targ; then
            warn "line already exists in $(pqw $short_targ):"
            echo "$line"
            continue

        elif [ "$DRY_RUN" ]; then
            [ "$first" ] && say "Would append to:$nc $short_targ"
            first=
            echo "$line"
            continue
        fi

        if [ "$VERBOSE" ]; then
            [ "$first" ] && say "Append to:$nc $short_targ"
            first=
            echo "$line"
        fi
        if [ "$BACKUP" ]; then
            local backfile=$targ$BACKUP
            [ -e $backfile ] || echo_run cp $targ $backfile
        fi
        echo "$line" >> $targ
    done
}

comment() {
    enter_function comment "$@"
    local line regex targ=$1
    shift
    for line; do
        regex="s=^\s*($(escape_regex "$line"))=# \1="
        _edit_ comment $targ "$regex"
    done
}

uncomment() {
    enter_function uncomment "$@"

    local line regex targ=$1
    shift
    for line; do
        regex="s=^#\s*($(escape_regex "$line"))=\1="
        _edit_ uncomment $targ "$regex"
    done
}


edit() {
    enter_function edit "$@"
    _edit_ edit "$@"
}

_edit_() {
    local caller=$1; shift
    require_args $caller "$1" "target file"

    local short_targ=$1
    local       targ=$PREFIX$1
    shift 1

    check_targ_file $targ || return
    [ ! -e $targ ] && error "Target file not found: $(pqw $short_targ)" && return
    local regex found first=true
    for regex; do

        if [ -z "$(sed -n -r "${regex}p" $targ)" ]; then
            warn "regular expression: >>$(pqnw "$regex")<<"
            yell "does not match file: $(pqnw $short_targ)"
            continue

        elif [ "$DRY_RUN" ]; then
            [ "$first" ] && say "Would $caller:$nc $short_targ"
            first=
            sed -n -r "${regex}p" $targ
            continue
        fi

        if [ "$VEBOSE" ]; then
            [ "$first" ] && say "$caller:$nc $short_targ"
            first=
            sed -n -r "${regex}p" $targ
        fi

        sed -i$BACKUP -r "$regex" $targ
    done
}

echo_run() {
    if [ -n "$DRY_RUN" ]; then
        say "Would run:"
        echo "$*" | sed "s=$THEME_DIR/==g"
        return
    fi

    if [ "$VERBOSE" ]; then
        say "Run:"
        echo "$*" | sed "s=$THEME_DIR/==g"
    fi
    "$@"
}

check_targ_dir() {
    local targ=$1  create=$2
    [ -n "$DRY_RUN" -a -n "$create" ] && return 0
    [ ! -e $targ ] && error "Target directory not found: $(pqw $short_targ)" && return 1
    [ ! -d $targ ] && error "Target is not a directory: $(pqw $short_targ)"  && return 1
    return 0
}

check_targ_file() {
    local targ=$1  create=$2
    [ -n "$DRY_RUN" -a -n "$create" ] && return 0
    [ ! -e $targ ] && error "Target file not found: $(pqw $short_targ)" && return 1
    [ ! -f $targ ] && error "Target is not a normal file: $(pqw $short_targ)"  && return 1
    return 0
}

error()  {
    echo "${err_co}Error:$bold_co $*$nc" >&2
    case $ERROR_MODE in
         fatal) exit 1   ;;
         ask|*) YES_no "Ignore this error" || exit 1;;
        ignore) ;;
    esac
    yell "Error ignored"
    return 0
}

fatal()  {
    echo "${err_co}Fatal Error:$bold_co $*$nc" >&2
    exit 1
}

say()    { echo "$text_co$*$nc"       ;}
yell()   { echo "$bold_co$*$nc"       ;}
pqh()    { echo "$text_co$*$high_co"  ;}
pqnh()   { echo  "$num_co$*$high_co"  ;}
pq()     { echo "$high_co$*$text_co"  ;}
pqn()    { echo  "$num_co$*$text_co"  ;}
pqw()    { echo "$text_co$*$bold_co"  ;}
pqnw()   { echo  "$num_co$*$bold_co"  ;}

warn()   { echo "${err_co}Warning:$bold_co $*$nc" ;}

set_colors() {
    local color_mode=${1:-$COLOR_MODE}
    : ${color_mode:=high}

    local e=$(printf "\e")

    if [ "$color_mode" != "off" ]; then
          black="$e[0;30m";     blue="$e[0;34m";      green="$e[0;32m";
           cyan="$e[0;36m";      red="$e[0;31m";     purple="$e[0;35m";
          brown="$e[0;33m";  lt_gray="$e[0;37m";    dk_gray="$e[1;30m";
        lt_blue="$e[1;34m"; lt_green="$e[1;32m";    lt_cyan="$e[1;36m";
         lt_red="$e[1;31m";  magenta="$e[1;35m";     yellow="$e[1;33m";
          white="$e[1;37m";  rev_red="$e[0;7;31m";       nc="$e[0m";
    fi

    case $color_mode in
        high) text_co=$lt_cyan;    bold_co=$yellow;     err_co=$lt_red;
               num_co=$magenta;  prompt_co=$lt_green;  time_co=$cyan;
              high_co=$white; ;;

         low) text_co=$nc;         bold_co=$lt_blue;    err_co=$red;
               num_co=$purple;   prompt_co=$green;     time_co=$cyan;
              high_co=$cyan; ;;

         off) ;;

           *) error "Invalid color mode: $color_mode";;
    esac
}
#------------------------------------------------------------------------------
# A collection of routines to ask Yes/No questions.  The default is in upper
# case.  The *_loud versions ignore quiet_mode.
#------------------------------------------------------------------------------
YES_no()      { _yes_no_  0  0  "(Y/n)"  "$1"; }
yes_NO()      { _yes_no_  1  1  "(y/N)"  "$1"; }
yes_no_loud() { _yes_no_ -1 -1 "((y/n))" "$1"; }
YES_no_loud() { _yes_no_ -1  0 "((Y/n))" "$1"; }
yes_NO_loud() { _yes_no_ -1  1 "((y/N))" "$1"; }

#------------------------------------------------------------------------------
# _yes_no_ quiet_ret default_ret yn_prompt prompt
# Immediately return quiet_ret if it is greater or equal to zero and we are in
# quiet_mode.  Return default_ret if the empty string is given and default_ret
# is greater than or equal to zero.  Otherwise return true on yes and false on
# no.
#------------------------------------------------------------------------------
_yes_no_() {
    local ans quiet_ret=$1 def_ret=$2 yn=$3 prompt=$4

    [ "$QUIET" -a $quiet_ret -ge 0 ] && return $quiet_ret

    while true; do
        echo -ne "$text_co$prompt$prompt_co $yn?$nc "
        read ans
        case x$ans in
            x[Yy]*) return 0;;
            x[Nn]*) return 1;;
                 x) [ $def_ret -ge 0 ] && return $def_ret;;
        esac

        [  -z "$ans" ] && echo -n 'You must answer "y" or "n".  '
        [  -n "$ans" ] && echo "bad answer: <$ans>"
        echo "Please try again"
    done
}
