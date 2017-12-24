#!/bin/bash

# Please change these defaults (if you want to)
COLOR="#b000b0"
COLOR="#FFFFFF"
COLOR="#a0a0a0"
BORDER="12x9"
BORDER=
TEXT="Live"
FONT_SIZE="32"
POSITION="340,490"

ME=$(basename $0)

usage() {
    cat <<Usage
Usage: $ME  [options] input.jpg output.jpg

Flags:
    -h|--help       Show this help.

Options:
    -b|--border      <WxH>     default: $BORDER
    -c|--color       <color>   default: $COLOR
    -f|--font-size   <number>  default: $FONT_SIZE
    -p|-position     <X,Y>     default: $POSITION
    -t|--text        <text>    default: $TEXT
Usage
    exit
}

help_error() {
    echo "$ME: $@.  Use -h for help.">&2
}

[ $# -gt 0 ] || usage

while [ $# -gt 0 ]; do
    case "$1" in
        -h|-help|--help)
            usage
            ;;
        -c|-color|--color)
            [ $# -ge 2 ] || help_error "expected <#NNNNNN> parameter after $1"
            COLOR=$2
            shift 2
            ;;
        -f|-font-size|--font-size)
            [ $# -ge 2 ] || help_error "expected parameter after $1"
            FONT_SIZE=$2
            shift 2
            ;;
        -b|-border|--border)    
            [ $# -ge 2 ] || help_error "expected <WxH> parameter after $1"
            BORDER=$2
            shift 2
            ;;
        -p|-postion|--postion)
            [ $# -ge 2 ] || help_error "expected <xxx,yyy> parameter after $1"
            POSITION=$2
            shift 2
            ;;
        -t|-text|--text)
            [ $# -ge 2 ] || help_error "expected text parameter after $1"
            TEXT=$2
            shift 2
            ;;
        -*)
            help_error "Unknown option: $1"
            ;;
        *)
            break
            ;;
    esac
done

[ $# -eq 2 ] || help_error "Expected exactly two arguments."

[ "$BORDER" ] && bopts="-shave $BORDER -mattecolor $COLOR -frame $BORDER"

if [ "$TEXT" ]; then
    convert $bopts -pointsize $FONT_SIZE -draw "text $POSITION '$TEXT'" -fill $COLOR $1 $2
else
    convert $bopts $1 $2
fi

