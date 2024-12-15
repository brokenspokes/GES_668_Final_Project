library(mapgl)
library(sf)

st_read("neighborhood_stats.gpkg") -> neighborhood_stats

mapboxgl()

mapboxgl(
  style = mapbox_style("satellite"),
  projection = "winkelTripel")

maplibre()

maplibre(
  style = maptiler_style("bright"),
  center = c(-43.23412, -22.91370),
  zoom = 14
) |>
  add_fullscreen_control(position = "top-left") |>
  add_navigation_control()

m1 <- mapboxgl()
m2 <- mapboxgl(mapbox_style("satellite-streets"))

compare(m1, m2)

nc <- st_read(system.file("shape/nc.shp", package="sf"))

m2 <- mapboxgl(bounds = nc) |>
  add_fill_layer(id = "nc_data",
                 source = nc,
                 fill_color = "blue",
                 fill_opacity = 0.5)

library(mapgl)
library(tigris)

options(tigris_use_cache = TRUE)

loving_roads <- roads("TX", "Loving")

mapboxgl(bounds = loving_roads) |>
  add_line_layer(
    id = "roads",
    source = loving_roads,
    line_color = "navy",
    line_opacity = 0.7
  )
