#!/bin/sh
set -eu
#
# pdfcrop.sh input output
#
input=$1
output=$2

mediabox=$(gs -dNOPAUSE -dBATCH -q -sDEVICE=bbox "$input" 2>&1 | tail -1 | cut -d' ' -f2-)
gs -o "$output" -dNOPAUSE -dBATCH -q -sDEVICE=pdfwrite -c "[/CropBox [$mediabox]" -c " /PAGES pdfmark" -f "$input"
