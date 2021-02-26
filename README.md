# mapstew
![](https://github.com/typebrook/mapstew/workflows/Hourly%20PBF%20update/badge.svg) ![](https://github.com/typebrook/mapstew/workflows/Daily%20PBF%20fetch/badge.svg)

This project uses Github workflow to generate MVT (Mapbox Vector Tile), and serves them as static resource on Github Pages.  

See the rendered tiles on https://typebrook.github.io/mapstew, tile schema is based on [OpenMapTiles](https://openmaptiles.org/schema/) with some custom changes.
  
## Quick Start
1. Fork this repo.
1. Enable **Gitub Action** in repo settings page:
   `https://github.com/<user>/<repo>/settings/actions`
1. Also enable **Github Pages** in repo settings page, pick `gh-pages` branch as source.
1. That's it!

## How it works?
1. Use Github workflow to fetch latest `osm.pbf` daily (Taiwan by default), and update it as [Github release asset](https://github.com/typebrook/mapstew/releases/tag/daily-taiwan-pbf) called `taiwan-daily.osm.obf`.


2. Use Github workflow to update `taiwan-daily.osm.pbf` release asset in step 1 (with `osmctools`). And also upload it as release asset called `taiwan-latest.osm.pb


3. Use Github workflow to generate tiles hourly (with `taiwan-latest.osm.pbf` from step 2), and commit them into `gh-pages` bran


With steps above, the static tile resource `http://typebrook.github.io/mapstew/tiles/{z}/{x}/{y}.pbf` are always updated with OSM with minimal delay.

## Stacks
- [`GOEFABRIK`](http://download.geofabrik.de/asia/taiwan.html) and [`Protomaps`](https://protomaps.com/) - Get daily osm.pbf.
- [`osmctools`](https://github.com/ramunasd/osmctools) - Update osm.pbf hourly. Here I use [custom docker image](https://hub.docker.com/r/osmtw/osmctools) (smaller size with `debian:stable-slim` to boost Github workflow) 
- [`tilemaker`](https://github.com/systemed/tilemaker) - Generate MVT directly from `osm.pbf` file.

## Limitation
1. The runner of Github workflow has limited computing power, so generate tiles worldwide houly is impossible. But for area of Taiwan, it could be done in 10 minutes.
