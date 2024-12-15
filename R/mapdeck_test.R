library(rdeck)
library(sf)

st_read("neighborhood_stats.gpkg") -> neighborhood_stats




rdeck_light <- rdeck(
  map_style = mapbox_dark(),
  theme = "kepler",
  initial_bounds = st_bbox(neighborhood_stats),
  height = 600
)

st_set_geometry(neighborhood_stats, "polygon") |>
  st_transform("WGS84") -> neighborhood_stats

rdeck_light |>
  add_polygon_layer(
    name = "Price to Assessment Ratio by Neighborhood",
    data = neighborhood_stats,
    opacity = 0.6,
    get_fill_color = scale_color_linear(
      regular_med_price,
      col_label = "Price Ratio"
    ),
    tooltip = c(Name, regular_mean_price),
    pickable = TRUE
  )
