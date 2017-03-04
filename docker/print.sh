#!/bin/sh
#
# print.sh input type output
#

set -exu
input=$1
type=$2
output=$3
tmpname=$(basename "$(mktemp -u printXXXXXX)")

gs	\
	-sOutputFile="${tmpname}-gray.pdf"	\
	-sDEVICE=pdfwrite	\
	-sColorConversionStrategy=Gray	\
	-dProcessColorModel=/DeviceGray	\
	-dCompatibilityLevel=1.5	\
	-dNOPAUSE	\
	-dBATCH "$input"

if [ "$type" = "tombo" ]; then
	cat << EOF > "${tmpname}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside,tombow]{jsbook}
\usepackage{pdfpages}
\pagestyle{empty}
\begin{document}
\includepdf[pages=-,noautoscale,offset=1in -1in]{${tmpname}-gray.pdf}
\end{document}
EOF
else
	cat << EOF > "${tmpname}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\usepackage{pdfpages}
\pagestyle{empty}
\advance \paperwidth 6truemm
\advance \paperheight 6truemm
\begin{document}
\includepdf[pages=-,noautoscale]{${tmpname}-gray.pdf}
\end{document}
EOF
fi

uplatex "$tmpname"
dvipdfmx "$tmpname"
if [ "$(echo "$output" | grep -c '\.ps$')" -ne 0 ]; then
	pdf2ps "${tmpname}.pdf" "${tmpname}.ps"
	mv "${tmpname}.ps" "$output"
else
	mv "${tmpname}.pdf" "$output"
fi
rm -rf "${tmpname}."* "${tmpname}-gray.pdf"
