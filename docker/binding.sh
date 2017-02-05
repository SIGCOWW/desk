#!/bin/sh
# binding.sh COVER BODY BACK_COVER OUTPUT

COVER=$1
BODY=$2
BACK=$3
OUTPUT=$4
TMPNAME=`basename $(mktemp -u bindingXXXXXX)`

cat << EOF > "${TMPNAME}.tex"
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
\includepdf{$COVER}
\blankpage
EOF

PAGES=`pdfinfo $BODY | grep 'Pages:' | sed -e 's/Pages:\s*//'`
for i in `seq 1 $PAGES`; do
	OFFSET="-3truemm"
	if [ `expr $i % 2` -eq 0 ]; then OFFSET="3truemm"; fi
	echo "\includepdf[pages=${i},noautoscale,offset=${OFFSET} 0]{${BODY}}" >> "${TMPNAME}.tex"
done

cat << EOF >> "${TMPNAME}.tex"
\blankpage
\includepdf{$BACK}
\end{document}
EOF

uplatex $TMPNAME
dvipdfmx $TMPNAME

gs	\
	-dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dEmbedAllFonts=true	\
	-sOutputFile=$OUTPUT -f "${TMPNAME}.pdf"
rm -rf ${TMPNAME}.*

