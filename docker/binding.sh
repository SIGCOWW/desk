#!/bin/sh
#
# binding.sh cover body back_cover output offset
#
set -exu
cover=$1
body=$2
back_cover=$3
output=$4
offset=$5
tmpname=$(basename "$(mktemp -u bindingXXXXXX)")

cat << EOF > "${tmpname}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\usepackage{pdfpages}
\usepackage{xcolor}
\definecolor{aliceblue}{rgb}{0.94, 0.97, 1.0}
\newcommand{\blankpage}{%
	\pagecolor{aliceblue}
	\mbox{}
	\clearpage
	\newpage
	\pagecolor{white}}
\pagestyle{empty}
\begin{document}
\includepdf{$cover}
\blankpage
EOF

pages=$(pdfinfo "$body" | grep 'Pages:' | sed -e 's/Pages:\s*//')
for i in $(seq 1 "$pages"); do
	ofs="-${offset}"
	if [ "$((i % 2))" -eq 0 ]; then ofs=$offset; fi
	echo "\includepdf[pages=${i},noautoscale,offset=${ofs} 0]{${body}}" >> "${tmpname}.tex"
done

cat << EOF >> "${tmpname}.tex"
\blankpage
\includepdf{$back_cover}
\end{document}
EOF

uplatex "$tmpname"
dvipdfmx "$tmpname"

gs	\
	-dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dEmbedAllFonts=true	\
	-sOutputFile="$output" -f "${tmpname}.pdf"
rm -rf "${tmpname}."*
