#!/bin/bash
LASTPREFIX=""
TARGETDIR="./docs/_generated/"
mkdir -p $TARGETDIR
grep -v '^\s*$\|^\s*\#' .env | while read -r line; do
	PREFIX=${line%%_*}
	if [ "$PREFIX" == "COMPOSE" ]; then
		continue
	fi
	FILENAME=${TARGETDIR}env-${PREFIX,,}-table.md 
	if [ "$PREFIX" != "$LASTPREFIX" ]; then
		echo '| Name | Default | Description' >> $FILENAME
		echo '| --- | --- | ---' >> $FILENAME
	fi
	echo $line | sed 's/ / | /; s/=/ | /; s/| #/| /; s/^/| /; s/${PWD}/./' | sed -r -e 's/\.\/([^ ]*)/`\.\/\1`/;'   >> $FILENAME
	LASTPREFIX=$PREFIX
done