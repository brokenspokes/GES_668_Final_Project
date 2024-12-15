library(tidyverse)
library(sf)
library(tmap)

tmap_mode("view")

st_read("neighborhood_stats.gpkg") -> neighborhood_stats

neighborhood_stats |>
  filter(unimproved_n > 10) |>
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
         diff_med_price_ratio = regular_med_price_ratio - vacant_med_price_ratio) -> unimproved_analysis_subset

tm_shape(unimproved_analysis_subset) +
  tm_polygons(col = "diff_mean_price_ratio",
              palette = "viridis")
