#! /bin/bash

LIST=tiles.list && touch $LIST

git status tiles/ --short | awk -v date="$(date +%s)" '{print date, $2}' | cat - $LIST >$LIST.bak

sort -u -k2 <$LIST.bak >$LIST
rm $LIST.bak
