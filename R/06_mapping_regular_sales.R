library(sf)
library(rdeck)
library(dplyr)

st_read("Data/neighborhood_stats.gpkg") |>
  filter(regular_n > 50) -> neighborhood_stats

rdeck_dark <- rdeck(map_style = mapbox_dark(),
                    theme = "kepler",
                    initial_bounds = st_bbox(neighborhood_stats),
                    height = 600
)

neighborhood_stats |>
  st_transform(4326) |>
  st_set_geometry("polygon") -> neighborhood_stats

rdeck_dark |>
  add_polygon_layer(
    name = "Assessment Value to Price ratio by Neighborhood",
    data = neighborhood_stats,
    opacity = 0.6,
    get_fill_color = scale_color_linear(
      regular_med_price_ratio,
      col_label = "Price Ratio"
    ),
    tooltip = c(Name, Population, regular_med_price_ratio, regular_med_price),
    pickable = TRUE
  ) -> med_assessment_value

med_assessment_value

