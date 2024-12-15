library(tidyverse)

readRDS("all_sales.rds") -> all_sales

all_sales |>
  filter(price > 25000,
         price < 1000000,
         price_ratio < 50) |>
  ggplot(aes(x = price,
             y = price_ratio)) +
  geom_point() +
  geom_smooth()
