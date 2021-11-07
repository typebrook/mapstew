#! /usr/bin/env bash

set -o pipefail

echo OSM_DOWNLOAD_URL $OSM_DOWNLOAD_URL
echo TARGET $TARGET
echo

if [[ $TARGET =~ '/' ]]; then
  DIR=${TARGET%/*}
  mkdir $DIR
else
  DIR=.
fi

[[ -n $OSM_DOWNLOAD_URL && -n $TARGET ]] || exit 1

# Check if iOSM PBF file is valid on latest action
artifact_url() {
  if [[ -z $REPO ]]; then
    echo Argument REPO is not specified, fail to get OSM PBF file from latest action
    return 1
  fi

  curl --silent https://api.github.com/repos/$REPO/actions/artifacts\?per_page\=1 \
  | jq -r "select(has(\"artifacts\")).artifacts[] | select(.name=\"$(basename $TARGET)\") | .archive_download_url" \
  | head -1
}

# Fetch OSM PBF file from latest action
get_pbf_file_from_artifact() {
  echo Artifact URL is $artifact_url

  if [[ -z $TOKEN_DOWNLOAD_ARTIFACT ]]; then
    echo Argument TOKEN_DOWNLOAD_ARTIFACT is not specified, fail to get OSM PBF file with Github API
    return 1
  else
    echo Downloading artifact from latest action
  fi

  curl -L -H "Authorization: token $TOKEN_DOWNLOAD_ARTIFACT" $artifact_url -o $TARGET.zip || return 1
  ls -alh $TARGET.zip && unzip $TARGET.zip -d $DIR/

  # If OSM PBF file from last artifact asset is outdated over 2 days, then drop it
  DIFF=$(( $(date +%s) - $(osmconvert --out-timestamp $TARGET | xargs date +%s -d)  ))
  if [[ $DIFF -gt $(( 86400 * 2 )) ]]; then
    rm $TARGET
    echo Last artifact is outdated with $DIFF seconds
    return 1
  else
    return 0
  fi
}

# Update OSM PBF file with osmctools
# $1 -> OSM PBF FILE with timestamp in 1 hour -> TARGET OSM PBF file
#       (Updated with osmupdate)                 (Clip by poly file with osm convert)
update_pbf_file() {
  [[ ! -e $1 ]] && return 1

  local ARGUMENT_POLY_FILE=${POLY_FILE:+-B=${POLY_FILE}}

  echo Updating OSM PBF file with osmctools...
  osmupdate --verbose --hour $1 $DIR/updated.hour.osm.pbf $ARGUMENT_POLY_FILE || mv $1 $DIR/updated.hour.osm.pbf
  osmupdate --verbose --minute $DIR/updated.hour.osm.pbf $DIR/updated.osm.pbf $ARGUMENT_POLY_FILE || {
    echo Fail to update $1 with osmupdate
    mv $1 $DIR/updated.osm.pbf
  }
  osmconvert --verbose $DIR/updated.osm.pbf -o=$TARGET -B=$POLY_FILE --drop-broken-refs

  [[ $1 != $TARGET ]] && rm $1
  [[ -e $TARGET ]] && rm $DIR/updated*
}

echo Checking latest artifacts...
artifact_url=$(artifact_url)

if [[ -n $artifact_url ]]; then
  get_pbf_file_from_artifact && [[ -e $TARGET ]] && update_pbf_file $TARGET
fi


# Get OSM PBF file from the given URL
if [[ ! -e $TARGET ]]; then
  echo Ready to download osm.pbf file from remote
  curl --verbose -LO $OSM_DOWNLOAD_URL --output-dir $DIR
  osm_file=$DIR/${OSM_DOWNLOAD_URL##*/}

  update_pbf_file $osm_file
fi

[[ -e $TARGET ]] && echo osm.pbf file $TARGET is here && exit 0
