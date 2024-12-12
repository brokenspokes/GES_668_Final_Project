library(tidyverse)
library(tmap)

readRDS("sales_of_interest.rds") |>
  as.data.frame() -> sales

readRDS("baltimore_land_use.rds") |>
  as.data.frame() |>
  select(- geom) -> property_land_use

st_read("Data/Neighborhood_Statistical_Area_(NSA)_Boundaries/Neighborhood_Statistical_Area_(NSA)_Boundaries.shp") |>
  mutate(Name = toupper(Name)) -> neighborhoods


left_join(sales, property_land_use, by = join_by(property == BLOCKLOT)) |>
  mutate(identifier = case_when(
    (NO_IMPRV == "Y" & is.na(BL_DSCTYPE))    ~ "unimproved",
    vacant_at_sale                           ~ "vacant",
    str_detect(BL_DSCTYPE, "AUTO|WAREHOUSE") ~ "unperforming",
    .default = "regular"),
    price_ratio = price / Total_Assessment) -> sale_with_land

sale_with_land |>
  group_by(NEIGHBOR, identifier) |>
  summarise(med_price_ratio = median(price_ratio), .groups = "keep") |>
  pivot_wider(id_cols = "NEIGHBOR",
              names_from = "identifier",
              values_from = "med_price_ratio") -> summary


filter(sale_with_land,
       identifier %in% c("vacant")) |>
  group_by(NEIGHBOR) |>
  summarise(mean_price_ratio = mean(price_ratio),
            median_price_ration = median(price_ratio)) %>%
  left_join(neighborhoods, ., by = join_by(Name == NEIGHBOR)) -> neighborhood_vacant_sales

tmap_mode("view")

tm_shape(neighborhood_vacant_sales) +
  tm_polygons(col = "mean_price_ratio",
              id = "Name",
              palette = "viridis",
              breaks = c(0, 1, 2, 5, 10, 15, 20),
              popup.vars = c("mean_price_ratio",
                             "median_price_ration"))

filter(sale_with_land,
       identifier == "unperforming") |>
  group_by(NEIGHBOR) |>
  summarise(mean_price_ratio = mean(price_ratio),
            median_price_ration = median(price_ratio)) %>%
  left_join(neighborhoods, ., by = join_by(Name == NEIGHBOR)) -> neighborhood_underperforming_sales

tmap_mode("view")

tm_shape(neighborhood_underperforming_sales) +
  tm_polygons(col = "mean_price_ratio",
              id = "Name",
              palette = "viridis",
              breaks = c(0, 1, 2, 5, 10, 15, 20),
              popup.vars = c("mean_price_ratio",
                             "median_price_ration"))

