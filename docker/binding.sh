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
	-dNOPAUSE -dBATCH -q -sDEVICE=pdfwrite \
	-dPDFSETTINGS=/ebook -dDownsampleColorImages=true -dColorImageResolution=300 \
	-sOutputFile="${tmpname}-font.pdf" -f "$body"

	cat << EOF > "${tmpname}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\usepackage{pdfpages}
\usepackage{xcolor}
\definecolor{cherryblossompink}{rgb}{1.0, 0.72, 0.77}
\newcommand{\blankpage}{%
	\pagecolor{cherryblossompink}
	\mbox{}
	\clearpage
	\newpage
	\pagecolor{white}}
\pagestyle{empty}
\begin{document}
\includepdf{$cover}
\blankpage
\includepdf[pages=-,noautoscale,offset=-2.75truemm 0in]{${tmpname}-font.pdf}
\blankpage
\includepdf{$back_cover}
\end{document}
EOF

uplatex "$tmpname"
dvipdfmx "$tmpname"
mv "${tmpname}.pdf" "$output"
rm -rf "${tmpname}."* "${tmpname}-font.pdf"
