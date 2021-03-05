#! /bin/sh

url=$({
curl https://protomaps.com/api/v1/extracts --data @- <<EOF
  {
    "token": "$PROTOMAPS_TOKEN",
    "region": {
      "type": "bbox",
      "data": [20.72799,118.1036,26.60305,122.9312]
    }
  }
EOF
} | jq -r .url)

for i in {1..360}; do
  response=$(curl $url)
  complete=$(jq -r .Complete <<<"$response")

  if [[ $complete == true ]]; then
    uuid=$(jq -r .Uuid <<<"$response")
    echo get uuid: $uuid
    curl -L "https://protomaps.com/extracts/$uuid/download" -o $OUTPUT
    break
  fi

  sleep 10
done

