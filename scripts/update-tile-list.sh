#! /bin/env sh

LIST=tiles.list && touch $LIST

git status tiles/ --short | awk -v date="$(date +%s)" '{print date, $2}' | cat - $LIST >$LIST.bak

<$LIST.bak sort -u -k2 >$LIST
rm $LIST.bak
