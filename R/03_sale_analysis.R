library(tidyverse)
library(tmap)
library(sf)
library(janitor)

readRDS("sales_of_interest.rds") |>
  as.data.frame() -> sales

readRDS("baltimore_land_use.rds") |>
  as.data.frame() |>
  select(-geom) -> property_land_use

st_read("Data/Neighborhood_Statistical_Area_(NSA)_Boundaries/Neighborhood_Statistical_Area_(NSA)_Boundaries.shp") |>
  mutate(Name = toupper(Name)) -> neighborhoods


left_join(sales, property_land_use, by = join_by(property == BLOCKLOT)) |>
  group_by(property, transfer_no) |>
  summarise(date = first(date),
            price = first(price),
            block = first(block.x),
            property = first(property),
            acct_id_full = first(acct_id_full.x),
            vacant_at_sale = first(vacant_at_sale),
            Land_Value = first(Land_Value),
            Improvement_Value = first(Improvement_Value),
            Total_Assessment = first(Total_Assessment),
            NEIGHBOR = first(NEIGHBOR),
            BL_DSCTYPE = first(BL_DSCTYPE),
            BL_DSCSTYL = first(BL_DSCSTYL),
            CM_DSCIUSE = first(CM_DSCIUSE),
            NO_IMPRV = first(NO_IMPRV),
            .groups = "keep") |>
  mutate(identifier = case_when(
    (NO_IMPRV == "Y" & is.na(BL_DSCTYPE))    ~ "unimproved",
    vacant_at_sale                           ~ "vacant",
    str_detect(BL_DSCTYPE, "AUTO|WAREHOUSE") ~ "unperforming",
    .default = "regular"),
    price_ratio = Total_Assessment / price) |>
  ungroup() -> all_sales

saveRDS(all_sales, "all_sales.rds")

all_sales |>
  group_by(NEIGHBOR, identifier) |>
  summarise(med_price_ratio = median(price_ratio),
            mean_price_ratio = mean(price_ratio),
            med_price = median(price),
            mean_price = mean(price),
            n = n(),
            .groups = "keep") |>
  pivot_wider(id_cols = "NEIGHBOR",
              names_from = "identifier",
              names_glue = "{identifier}_{.value}",
              values_from = c("med_price_ratio",
                              "mean_price_ratio",
                              "med_price",
                              "mean_price",
                              "n")) %>%
  left_join(neighborhoods, ., by = join_by(Name == NEIGHBOR)) |>
  mutate(pct_blk = Blk_AfAm / Population,
         pct_wht = White / Population) |>
  select(Name,
         Population,
         pct_blk,
         pct_wht,
         starts_with(c("vacant",
                       "unimproved",
                       "unperforming",
                       "regular"))) -> neighborhood_stats

saveRDS(neighborhood_stats, "Data/neighborhood_stats.rds")
st_write(neighborhood_stats, "Data/neighborhood_stats.gpkg", append = FALSE)
