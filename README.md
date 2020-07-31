# mapstew
![](https://github.com/typebrook/mapstew/workflows/Hourly%20PBF%20update/badge.svg) ![](https://github.com/typebrook/mapstew/workflows/Daily%20PBF%20fetch/badge.svg)

This project uses Github workflow to generate MVT (Mapbox Vector Tile), and serves them as static resource on Github Pages.  

See https://typebrook.github.io/mapstew, tile schema is based on [OpenMapTiles](https://openmaptiles.org/schema/), and rendered with Mapbox GL JS and styles from [MapTiler](https://www.maptiler.com/maps/).

## Stacks
- [**Goefabrik**](http://download.geofabrik.de/asia/taiwan.html)
  Get daily osm.pbf.
- [**osmctools**](https://github.com/ramunasd/osmctools)
  Update osm.pbf hourly. Here I use [custom docker image](https://hub.docker.com/r/osmtw/osmctools) (smaller size with `debian:stable-slim` to boost Github workflow) 
- [**tilemaker**](https://github.com/systemed/tilemaker)
  Generate MVT directly from `osm.pbf` file.
  
## Quick Start
1. Fork this repo.
1. Enable **Gitub Action** in repo settings page:
   `https://github.com/<user>/<repo>/settings/actions`
1. Also enable **Github Pages** in repo settings page, pick `gh-pages` branch as source.
1. That's it! Updated tiles would be commited into `gh-pages` hourly. And in **Github Pages**, you should observe some map features are changed by time.

## How it works?

## Limitation