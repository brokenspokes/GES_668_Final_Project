library(readr)
library(tidyverse)
library(sf)
library(janitor)
library(lubridate)
library(tidyr)
library(purrr)
library(tmap)

vacants <- read.csv("Data/VBNs_All_112624.csv")
MD_Real_Property_Assessments <- read.csv("Data/MD_Real_Property_Assessments.csv")

MD_Real_Property_Assessments |>
  filter(`Jurisdiction.Code..MDP.Field..JURSCODE.` == "BACI") |>
  select(county_key = `RECORD.KEY..County.Code..SDAT.Field..1.`,
         acct_id = `Account.ID..MDP.Field..ACCTID.`,
         block = `Block..MDP.Field..BLOCK..SDAT.Field..40.`,
         lot = `Lot..MDP.Field..LOT..SDAT.Field..41.`,
         sale_1_transfer_no = `SALES.SEGMENT.1..Transfer.Number..MDP.Field..TRANSNO1..SDAT.Field..79.`,
         sale_1_grantor = `SALES.SEGMENT.1..Grantor.Name..MDP.Field..GRNTNAM1..SDAT.Field..80.`,
         sale_1_type = `SALES.SEGMENT.1..How.Conveyed.Ind...MDP.Field..CONVEY1..SDAT.Field..87.`,
         sale_1_date = `SALES.SEGMENT.1..Transfer.Date..YYYY.MM.DD...MDP.Field..TRADATE..SDAT.Field..89.`,
         sale_1_price = `SALES.SEGMENT.1..Consideration..MDP.Field..CONSIDR1..SDAT.Field..90.`,
         sale_1_mkt_land_value = `SALES.SEGMENT.1..Mkt.Land.Value..SDAT.Field..95.`,
         sale_1_mkt_improvement_value = `SALES.SEGMENT.1..Mkt.Improvement.Value..SDAT.Field..96.`,
         sale_2_transfer_no = `SALES.SEGMENT.2..Transfer.Number..SDAT.Field..99.`,
         sale_2_grantor = `SALES.SEGMENT.2..Grantor.Name..SDAT.Field..100.`,
         sale_2_type = `SALES.SEGMENT.2..How.Conveyed.Ind...SDAT.Field..107.`,
         sale_2_date = `SALES.SEGMENT.2..Transfer.Date..YYYY.MM.DD...SDAT.Field..109.`,
         sale_2_price = `SALES.SEGMENT.2..Consideration..SDAT.Field..110.`,
         sale_2_mkt_land_value = `SALES.SEGMENT.2..Mkt.Land.Value..SDAT.Field..115.`,
         sale_2_mkt_improvement_value = `SALES.SEGMENT.2..Mkt.Improvement.Value..SDAT.Field..116.`,
         sale_3_transfer_no = `SALES.SEGMENT.3..Grantor.Name..SDAT.Field..120.`,
         sale_3_grantor = `SALES.SEGMENT.2..Grantor.Name..SDAT.Field..100.`,
         sale_3_type = `SALES.SEGMENT.3..How.Conveyed.Ind...SDAT.Field..127.`,
         sale_3_date = `SALES.SEGMENT.3..Transfer.Date..YYYY.MM.DD...SDAT.Field..129.`,
         sale_3_price = `SALES.SEGMENT.3..Consideration..SDAT.Field..130.`,
         sale_3_mkt_land_value = `SALES.SEGMENT.3..Mkt.Land.Value..SDAT.Field..135.`,
         sale_3_mkt_improvement_value = `SALES.SEGMENT.3..Mkt.Improvement.Value..SDAT.Field..136.`) |>
  mutate(acct_id_full = paste0(county_key, acct_id),
         BLOCKLOT = paste0(trimws(block), trimws(lot))) -> sales

mutate(vacants,
       DateNotice = as.POSIXct(DateNotice, format = "%m/%d/%Y %H:%M"),
       DateAbate = as.POSIXct(DateAbate, format = "%m/%d/%Y %H:%M"),
       DateCancel = as.POSIXct(DateCancel, format = "%m/%d/%Y %H:%M"),
       BLOCKLOT = gsub(" ", "", BLOCKLOT),
       date_terminate = coalesce(DateAbate, DateCancel)) -> dates

sales |>
  mutate(across(starts_with("sale_"), as.character)) |>
  pivot_longer(cols = starts_with("sale_"),
               names_to = c("sale", ".value"),
               names_pattern = "sale_(\\d+)_(.*)",
               values_drop_na = TRUE
  ) -> all_sales

filter(all_sales,
       !(date == "0000.00.00")
) |>
  mutate(property = gsub(" ", "", BLOCKLOT),
         date = as.POSIXct(date, format = "%Y.%m.%d")) -> sales_valid_date

sales_valid_date |>
  left_join(dates, by = join_by(property == BLOCKLOT)) |>
  mutate(
    vacant_at_sale = (date >= DateNotice) & ((is.na(date_terminate) | date <= date_terminate))
  ) |>
  group_by(BLOCKLOT, sale) |>
  summarise(across(everything(), first),
            vacant_at_sale = any(vacant_at_sale, na.rm = TRUE)
  ) |>
  ungroup() -> vacant_sale

MD_Real_Property_Assessments |>
  select(county_key = `RECORD.KEY..County.Code..SDAT.Field..1.`,
         acct_id = `Account.ID..MDP.Field..ACCTID.`,
         block = `Block..MDP.Field..BLOCK..SDAT.Field..40.`,
         lot = `Lot..MDP.Field..LOT..SDAT.Field..41.`,
         starts_with(c("BASE.CYCLE.DATA",
                       "PRIOR.ASSESSMENT.YEAR",
                       "CURRENT.CYCLE.DATA",
                       "CURRENT.ASSESSMENT.YEAR",
                       "PRIOR.ASSESSMENT.YEAR.3")
         )) |>
  mutate(acct_id_full = paste0(county_key, acct_id),
         BLOCKLOT = paste0(trimws(block), trimws(lot))) -> assessments

# Properties are assessed once every three years, with the base value representing the previous
# assessment and the current cycle representing the current assessment. We use the base value for the
# three years prior to the existing assessment and the current one for the three years after. Although there
# are phase-in assessments, generally the value does not change so much over those years.

assessments |>
  mutate(assessment_year = floor(`CURRENT.CYCLE.DATA..Date.Assessed..YYYY.MM...MDP.Field..LASTASSD..SDAT.Field..169.`),
         base_years = map(assessment_year, ~ seq(.x - 3, .x - 1)),
         current_years = map(assessment_year, ~ seq(.x, .x + 2))
  ) |>
  rowwise() |>
  mutate(
    years = list(c(base_years, current_years)),
    land_values = list(c(rep(`BASE.CYCLE.DATA..Land.Value..SDAT.Field..154.`, length(base_years)),
                         rep(`CURRENT.CYCLE.DATA..Land.Value..MDP.Field.Names..NFMLNDVL..CURLNDVL..and.SALLNDVL..SDAT.Field..164.`, length(current_years)))),
    improvement_values = list(c(rep(`BASE.CYCLE.DATA..Improvements.Value..SDAT.Field..155.`, length(base_years)),
                                rep(`CURRENT.CYCLE.DATA..Improvements.Value..MDP.Field.Names..NFMIMPVL..CURIMPVL..and.SALIMPVL..SDAT.Field..165.`, length(current_years)))),
  ) |>
  unnest(c(years, land_values, improvement_values)) |>
  select(county_key,
         acct_id_full,
         BLOCKLOT,
         Year = years,
         Land_Value = land_values,
         Improvement_Value = improvement_values) |>
  mutate(Total_Assessment = Land_Value + Improvement_Value) -> long_assessment

vacant_sale |>
  select(property,
         transfer_no,
         acct_id,
         acct_id_full,
         date,
         type,
         price,
         block,
         vacant_at_sale) |>
  mutate(Year = year(date),
         acct_id_full = paste0("0", acct_id_full),
         price = as.numeric(price),
         block = trimws(block)) |>
  left_join(long_assessment, by = c("property" = "BLOCKLOT", "Year" = "Year")
  ) |>
  filter(price > 0,
         Total_Assessment > 0) |>
  select(-acct_id_full.y) |>
  rename(acct_id_full = acct_id_full.x) -> sale_with_value

saveRDS(sale_with_value, "sales_of_interest.rds")

## we are only interested in sales where we have a sale price and an assessment value
