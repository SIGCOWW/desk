#!/bin/sh
REDPEN_DIR="/redpen/bin"
FILES=`grep -oE "[a-zA-Z0-9]+\.re" "catalog.yml"`

LOGFILE=""
PREFIX=""
"${REDPEN_DIR}/redpen" -c "${REDPEN_DIR}/redpen-conf.xml" -r plain2 -l 1000 $FILES | while IFS= read line; do
	# Document
	if [ `echo "$line" | grep -c 'Document: '` -ne 0 ] ; then
		if [ -n "$LOGFILE" ]; then echo -e "\n\n"; fi
		echo -e "\e[33;41m${line}       \e[m"
		LOGFILE="redpen-"`echo ${line} | sed -e 's/Document: //' -e 's/\.re//'`".log"
		PREFIX=""
		continue
	fi

	TMP=`echo "$line" | sed -e 's/\s//'`
	# Number
	if [ `echo "$line" | grep -c 'Line: '` -ne 0 ] ; then
		echo -e "${PREFIX}\e[32m${line}\e[m"
		echo -e "${PREFIX}${TMP}" >> $LOGFILE
		PREFIX="\n"
		continue
	fi

	# Sentence
	if [ `echo "$line" | grep -c 'Sentence: '` -ne 0 ] ; then
		echo -e "\e[36m${line}\e[m"
		echo "$TMP" >> $LOGFILE
		continue
	fi

	# Message
	echo "$line"
	echo "$TMP" >> $LOGFILE
done

