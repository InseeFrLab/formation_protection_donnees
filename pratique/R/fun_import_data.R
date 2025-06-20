# Import des données
# La construction des données est réalisée par pratique/R/prepa_data.R

import_lfs <- function(){
  data.table::fread("../../data/lfs_2023.csv") %>%
    mutate( across( c(-HHID, -AGE, -IS_CHOM), as.factor))
}

import_meta_lfs <- function(){
  data.table::fread("../../data/meta_lfs_2023.csv")
}

