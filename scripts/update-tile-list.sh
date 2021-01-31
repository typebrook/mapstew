#! /bin/bash

LIST=tiles.list && touch $LIST
LAST_MONTH_TIMESTAMP=$(date --date='-1 month' +%s)

git status tiles/ --short | awk -v date="$(date +%s)" '{print date, $2}' \
| cat - $LIST \
| while read timestamp tile; do
  # remove entries that over a month ago
  [[ $timestamp -lt $LAST_MOTH_TIMESTAMP ]] && break
  echo $timestamp $tile
done >$LIST.bak

sort -u -k2 <$LIST.bak >$LIST
rm $LIST.bak
