.PHONY: tiles

all: tiles localhost

tiles: data/taiwan-latest.osm.pbf 
	tilemaker $< --output=tiles/ --config resources/config-mapstew.json --process resources/process-mapstew.lua

clean:
	rm -rf tiles/ data/ && git reset --hard

data/taiwan-latest.osm.pbf:
	mkdir -p data/
	cd data/ && \
	curl -LO https://github.com/typebrook/mapstew/releases/download/daily-taiwan-pbf/$(notdir $@)

data/taipei-latest.osm.pbf: data/taiwan-latest.osm.pbf
	osmconvert $< -b=121.346,24.926,121.676,25.209 --drop-broken-refs -o=$@

localhost:
	ls styles/* resources/tiles.json | xargs sed -i 's#https://typebrook.github.io/mapstew/#http://localhost:8000/#'
	xdg-open http://localhost:8000
	python3 -m http.server
