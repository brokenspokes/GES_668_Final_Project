library(tidyverse)
library(dplyr)
library(sf)
readRDS("Data/neighborhood_stats.rds") |>
  st_drop_geometry() -> all_sales

all_sales |>
  filter(regular_med_price_ratio < 10,
         regular_med_price < 500000) |>
  ggplot(aes(x = regular_med_price,
             y = regular_med_price_ratio)) +
  geom_point(aes(col = pct_blk)) +
  geom_smooth()
