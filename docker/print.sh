#!/bin/sh
# print.sh INPUT TYPE OUTPUT

INPUT=$1
TYPE=$2
OUTPUT=$3
TMPNAME=`basename $(mktemp -u printXXXXXX)`
gs	\
	-sOutputFile="${TMPNAME}-gray.pdf"	\
	-sDEVICE=pdfwrite	\
	-sColorConversionStrategy=Gray	\
	-dProcessColorModel=/DeviceGray	\
	-dCompatibilityLevel=1.5	\
	-dNOPAUSE	\
	-dBATCH $INPUT

if [ "$TYPE" = "tombo" ]; then
	cat << EOF > "${TMPNAME}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside,tombow]{jsbook}
\usepackage{pdfpages}
\pagestyle{empty}
\begin{document}
\includepdf[pages=-,noautoscale,offset=1in -1in]{${TMPNAME}-gray.pdf}
\end{document}
EOF
else
	cat << EOF > "${TMPNAME}.tex"
\documentclass[uplatex,dvipdfmx,b5paper,oneside]{jsbook}
\usepackage{pdfpages}
\pagestyle{empty}
\advance \paperwidth 6truemm
\advance \paperheight 6truemm
\begin{document}
\includepdf[pages=-,noautoscale]{${TMPNAME}-gray.pdf}
\end{document}
EOF
fi

uplatex $TMPNAME
dvipdfmx $TMPNAME
if [ `echo "$OUTPUT" | grep -c '\.ps$'` -ne 0 ]; then
	pdf2ps "${TMPNAME}.pdf" "${TMPNAME}.ps"
	mv "${TMPNAME}.ps" $OUTPUT
else
	mv "${TMPNAME}.pdf" $OUTPUT
fi
rm -rf ${TMPNAME}.* ${TMPNAME}-gray.pdf

