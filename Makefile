all:
	tilemaker ~/data/taipei-latest.osm.pbf --output=tiles/ --config resources/config-openmaptiles.json --process resources/process-openmaptiles.lua
