#! /usr/bin/env bash

set -o pipefail

echo GEOFABRIK_DOWNLOAD_URL $GEOFABRIK_DOWNLOAD_URL
echo TARGET $TARGET
echo

[[ -n $GEOFABRIK_DOWNLOAD_URL && -n $TARGET ]] || exit 1

# Check if iOSM PBF file is valid on latest action
artifact_url() {
  if [[ -z $REPO ]]; then
    echo Argument REPO is not specified, fail to get OSM PBF file from latest action
    return 1
  fi

  curl --silent https://api.github.com/repos/$REPO/actions/artifacts\?per_page\=1 \
  | jq -r "select(has(\"artifacts\")).artifacts[] | select(.name=\"$TARGET\") | .archive_download_url" \
  | head -1
}

# Fetch OSM PBF file from latest action
get_pbf_file_from_artifact() {
  echo Artifact URL is $artifact_url

  if [[ -z $TOKEN_DOWNLOAD_ARTIFACT ]]; then
    echo Argument TOKEN_DOWNLOAD_ARTIFACT is not specified, fail to get OSM PBF file with Github API
    return 1
  else
    echo Dwnloading artifact from latest action
  fi

  curl --silent -L -H "Authorization: token $TOKEN_DOWNLOAD_ARTIFACT" $artifact_url -o $TARGET.zip || return 1
  ls -alh $TARGET.zip && unzip $TARGET.zip
}

# Update OSM PBF file with osmctools
update_pbf_file() {
  [[ ! -e $TARGET ]] && return 1

  local ARGUMENT_POLY_FILE=
  [[ -n $POLY_FILE ]] && ARGUMENT_POLY_FILE="-B=$POLYFILE"

  echo Updating OSM PBF file with osmctools...
  osmupdate --verbose $TARGET updated.osm.pbf --hour ARGUMENT_POLY_FILE || {
    echo Fail to update $TARGET with osmupdate
    mv $TARGET updated.osm.pbf
  }
  osmconvert --verbose updated.osm.pbf -o=$TARGET -B=$POLY_FILE --drop-broken-refs
}

echo Checking latest artifacts...
artifact_url=$(artifact_url)

if [[ -n $artifact_url ]]; then
  get_pbf_file_from_artifact && \
  update_pbf_file || \
  {
    echo Fail to download artifact from latest action
    # If fail to featch OSM PBF file, just remove it
    [[ -e $TARGET ]] && rm $TARGET
  }
fi


# Get OSM PBF file from Geofabrik
if [[ ! -e $TARGET ]]; then
  echo Ready to download osm.pbf file from Geofabrik
  curl -L $GEOFABRIK_DOWNLOAD_URL -o $TARGET && \
  update_pbf_file
fi

[[ -e $TARGET ]] && echo osm.pbf file $TARGET is here && exit 0
