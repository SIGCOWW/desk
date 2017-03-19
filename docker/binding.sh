#!/bin/sh
set -eu
#
# binding.sh cover body back_cover output
#
cover=$1
body=$2
back_cover=$3
output=$4
tmpname=$(basename "$(mktemp -u bindingXXXXXX)")
gs	\
	-dNOPAUSE -dBATCH -q -sDEVICE=pdfwrite -dEmbedAllFonts=true	\
	-sOutputFile="${tmpname}-font.pdf" -f "$body"

	cat << EOF > "${tmpname}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\usepackage{pdfpages}
\pagestyle{empty}
\begin{document}
\includepdf[pages=-,noautoscale,offset=-0in 0in]{${tmpname}-font.pdf}
\end{document}
EOF

uplatex "$tmpname"
dvipdfmx "$tmpname"
mv "${tmpname}.pdf" "$output"
rm -rf "${tmpname}."* "${tmpname}-font.pdf"
