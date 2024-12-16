library(readr)
library(sf)
library(tidyverse)
library(janitor)

st_read("Data/baltimore_real_prop_boundaries.gpkg") -> baltimore

baltimore |>
  mutate(BLOCKLOT = gsub(" ", "", BLOCKLOT),
         NEIGHBOR = trimws(NEIGHBOR),
         BLOCK = trimws(BLOCK)) |>
  select(BLOCK,
         BLOCKLOT,
         VACIND,
         NO_IMPRV,
         NEIGHBOR,
         OWNER_1) -> baltimore_land_use

# pulling all property in from baltimore city

read.csv("Data/MD_Real_Property_Assessments.csv") -> md_real_prop

md_real_prop |>
  select(county_key = `RECORD.KEY..County.Code..SDAT.Field..1.`,
         acct_id = `Account.ID..MDP.Field..ACCTID.`,
         block = `Block..MDP.Field..BLOCK..SDAT.Field..40.`,
         lot = `Lot..MDP.Field..LOT..SDAT.Field..41.`) |>
  mutate(acct_id_full = paste0("0", county_key, acct_id),
         block = trimws(block),
         lot = trimws(lot),
         BLOCKLOT = trimws(paste0(block, lot))) -> md_acct_ids

# adding in state tax characteristics like tax account id

left_join(baltimore_land_use,
          md_acct_ids,
          by = join_by(BLOCKLOT)) -> baltimore_acct_ids

read.csv("/Users/jspokes/Documents/R_Projects/Final_Project_Presentation/Data/MD_CAMA_Building_Characteristics.csv") -> cama_bldg

cama_bldg |>
  filter(JURSCODE == "BACI") |>
  select(ACCTID,
         BL_DSCTYPE,
         BL_DSCSTYL) |>
  mutate(ACCTID = gsub(" ", "", ACCTID)) -> cama_bldg_simple

left_join(baltimore_acct_ids,
          cama_bldg_simple,
          by = join_by(acct_id_full == ACCTID)) -> baltimore_cama_bldg

# adding on building type

read.csv("Data/MD_CAMA_Core.csv") -> cama_core

cama_core |>
  filter(JURSCODE == "BACI") |>
  select(ACCTID,
         CM_DSCIUSE) |>
  mutate(ACCTID = gsub(" ", "", ACCTID)) -> cama_core_simple

left_join(baltimore_cama_bldg,
          cama_core_simple,
          by = join_by(acct_id_full == ACCTID)) -> baltimore_cama_all

saveRDS(baltimore_cama_all, "baltimore_land_use.rds")

