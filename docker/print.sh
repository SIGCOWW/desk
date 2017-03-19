#!/bin/sh
set -eu
#
# print.sh input output
#
input=$1
output=$2
tmpname=$(basename "$(mktemp -u printXXXXXX)")

gs	\
	-sOutputFile="${tmpname}-gray.pdf"	\
	-sDEVICE=pdfwrite	\
	-sColorConversionStrategy=Gray	\
	-dProcessColorModel=/DeviceGray	\
	-dEmbedAllFonts=true	\
	-dCompatibilityLevel=1.5	\
	-dNOPAUSE	\
	-dBATCH -q "$input"

	cat << EOF > "${tmpname}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\usepackage{pdfpages}
\pagestyle{empty}
\advance \paperwidth 6truemm
\advance \paperheight 6truemm
\begin{document}
\includepdf[pages=-,noautoscale,offset=-0in 0in]{${tmpname}-gray.pdf}
\end{document}
EOF

uplatex "$tmpname"
dvipdfmx "$tmpname"
if [ "$(echo "$output" | grep -c '\.ps$')" -ne 0 ]; then
	pdf2ps "${tmpname}.pdf" "${tmpname}.ps"
	mv "${tmpname}.ps" "$output"
else
	mv "${tmpname}.pdf" "$output"
fi
rm -rf "${tmpname}."* "${tmpname}-gray.pdf"
