library(sf)
library(rdeck)
library(tidyverse)
library(tidycensus)

st_read("Data/neighborhood_stats.gpkg") |>
  select(Name,
         ends_with("_n")) |>
  pivot_longer(cols = ends_with("_n"),
               names_to = "Sale_Type",
               values_to = "N_Sales") |>
  mutate(Sale_Type = gsub("_n", "", Sale_Type)) -> pivot

sale_dot_density <- as_dot_density(pivot,
                                   value = "N_Sales",
                                   values_per_dot = 10,
                                   group = "Sale_Type")

rdeck_dark <- rdeck(map_style = mapbox_dark(),
                    theme = "kepler",
                    initial_bounds = st_bbox(pivot),
                    height = 600
)

sale_dot_density |>
  st_transform(4326) |>
  st_set_geometry("position") -> sale_dot_density

rdeck_dark |>
  add_scatterplot_layer(
    name = "Sales by type of property (10 per dot)",
    data = sale_dot_density,
    radius_min_pixels = 1,
    radius_max_pixels = 5,
    radius_scale = 5,
    opacity = 0.6,
    get_fill_color = scale_color_category(
      Sale_Type,
      palette = scales::brewer_pal("qual"),
      col_label = "Sale Type"
    )
  ) -> mapdeck_output
