#! /bin/bash

LIST=tiles.list && touch $LIST
LAST_MONTH_TIMESTAMP=$(date --date='-1 month' +%s)

# Put updated tiles into tiles.list
# First column is current timestamp, second column is tile path
git status tiles/ --short | awk -v date="$(date +%s)" '{print date, $2}' \
| cat - $LIST \
| while read timestamp tile; do
  # Remove entries that over a month ago
  [[ $timestamp -lt $LAST_MOTH_TIMESTAMP ]] && break
  echo $timestamp $tile
done >$LIST.bak

# Remove duplicate tiles (tiles also updated before) and sort them with newer timestamp
sort -u -k2 <$LIST.bak | sort --reverse >$LIST
rm $LIST.bak
