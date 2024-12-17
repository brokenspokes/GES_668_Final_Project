library(tidyverse)
library(sf)
library(tmap)
library(rdeck)

st_read("Data/neighborhood_stats.gpkg") -> neighborhood_stats

neighborhood_stats |>
  filter(vacant_n > 25) |>
  select(Name,
         Population,
         pct_blk,
         pct_wht,
         vacant_med_price_ratio,
         vacant_mean_price_ratio,
         vacant_mean_price,
         vacant_med_price,
         vacant_n,
         regular_med_price_ratio,
         regular_mean_price_ratio,
         regular_mean_price,
         regular_med_price,
         regular_n) |>
  mutate(diff_mean_price_ratio = regular_mean_price_ratio - vacant_mean_price_ratio,
         diff_med_price_ratio = regular_med_price_ratio - vacant_med_price_ratio) -> vacant_analysis_subset

rdeck_dark <- rdeck(map_style = mapbox_dark(),
                    theme = "kepler",
                    initial_bounds = st_bbox(vacant_analysis_subset),
                    height = 600
)

vacant_analysis_subset |>
  st_transform(4326) |>
  st_set_geometry("polygon") -> vacant_analysis_subset

rdeck_dark |>
  add_polygon_layer(
    name = "Comparative Assessment Value to Price ratio by Neighborhood",
    data = vacant_analysis_subset,
    opacity = 0.6,
    get_fill_color = scale_color_linear(
      diff_med_price_ratio,
      col_label = "Difference in median price ratio"
    ),
    tooltip = c(Name,
                Population,
                regular_med_price_ratio,
                regular_med_price,
                vacant_med_price_ratio,
                vacant_med_price,
                diff_med_price_ratio),
    pickable = TRUE
  ) -> med_diff_assessment_value

med_diff_assessment_value
