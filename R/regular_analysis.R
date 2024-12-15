library(tidyverse)
library(sf)
library(tmap)

tmap_mode("view")

st_read("neighborhood_stats.gpkg") -> neighborhood_stats


neighborhood_stats |>
  filter(regular_n > 50) |>
  select(Name,
         Population,
         pct_blk,
         pct_wht,
         regular_med_price_ratio,
         regular_mean_price_ratio,
         regular_mean_price,
         regular_med_price,
         regular_n) -> regular_analysis_subset

cor.test(regular_analysis_subset$regular_med_price_ratio,
         regular_analysis_subset$regular_med_price)


ggplot(regular_analysis_subset,
       aes(x = regular_med_price,
           y = regular_med_price_ratio)) +
  geom_point() +
  geom_smooth()
