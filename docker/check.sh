#!/bin/sh
set -eu
REDPEN_DIR="/redpen/bin"
logfile=""
prefix=""
files=$(grep -oE "[a-zA-Z0-9]+\.re" "catalog.yml")
cd articles/
"${REDPEN_DIR}/redpen" -c "${REDPEN_DIR}/redpen-conf.xml" -r plain2 -l 1000 $files | while IFS= read -r line; do
	# Document
	if [ "$(echo "$line" | grep -c 'Document: ')" -ne 0 ]; then
		if [ -n "$logfile" ]; then echo ""; echo ""; fi
		echo -e "\033[33;41m${line}       \033[m"
		logfile="redpen-$(echo "$line" | sed -e 's/Document: //' -e 's/\.re//').log"
		prefix=""
		continue
	fi

	tmp=$(echo "$line" | sed -e 's/\s//')
	# Number
	if [ "$(echo "$line" | grep -c 'Line: ')" -ne 0 ]; then
		echo -e "${prefix}\033[32m${line}\033[m"
		echo "${prefix}${tmp}" >> "$logfile"
		prefix="\n"
		continue
	fi

	# Sentence
	if [ "$(echo "$line" | grep -c 'Sentence: ')" -ne 0 ]; then
		echo -e "\033[36m${line}\033[m"
		echo "$tmp" >> "$logfile"
		continue
	fi

	# Message
	echo "$line"
	echo "$tmp" >> "$logfile"
done
