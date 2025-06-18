# Téléchargement du fichier individuel de l'EEC 

library(dplyr)

filename <- "data/lfs_2023.csv"

taux_echantillon <- 0.1

if(!dir.exists("data/")) dir.create("data/")

if(file.exists(filename)){
  
  lfs_2023 <- data.table::fread(filename) %>%
    mutate( across( c(-HHID, -AGE, -IS_CHOM), as.factor))
  
}else{
  
  options(timeout = 6000)
  
  if(! file.exists("data/lfs_micro_fr_2023.zip")){
    download.file(
      destfile = "data/lfs_micro_fr_2023.zip",
      url = "https://www.insee.fr/fr/statistiques/fichier/8241122/FD_csv_EEC23.zip"
    )
  }
  
  if(! file.exists("data/FD_csv_EEC23.csv")){
    unzip(zipfile = "data/lfs_micro_fr_2023.zip", exdir = "data")
  }
  
  if(! file.exists("data/populations.zip")){
    download.file(
      destfile = "data/populations.zip",
      url = "https://www.insee.fr/fr/statistiques/fichier/7739582/ensemble.zip"
    )
  }
  if(! file.exists("data/donnees_arrondissements.csv")){
    unzip(zipfile = "data/populations.zip", exdir = "data")
  }
  
  
  lfs_micro_fr_2023 = data.table::fread(
    "data/FD_csv_EEC23.csv"
  ) %>% 
    # On conserve uniquement les ménages dont la personne est âgée entre 15 et 89 ans
    filter(CHAMP_M_15_89 == 1) %>% 
    select(-CHAMP_M_15_89, -EXTRIAN)
  
  # Documentation du fichier
  # https://www.insee.fr/fr/statistiques/8241122#dictionnaire
  
  pop_arrondissements <- read.csv2(
    "data/donnees_arrondissements.csv",
    header = TRUE
  ) %>% 
    filter(REG %in% c(11, 94, 76, 28))
  
  # Reconstruction d'une variable d'âge
  set.seed(1234)
  ages <- tibble(
    AGE6 = sort(unique(lfs_micro_fr_2023$AGE6))
  ) %>% 
    mutate(
      ages_ub = dplyr::lead(AGE6-1, default = 120)
    )
  
  lfs_micro_fr_2023 <- lfs_micro_fr_2023 %>% 
    left_join(ages, by = "AGE6") %>% 
    mutate(
      AGE = round(runif(n(), min = AGE6, max = ages_ub))
    ) %>% 
    select(-ages_ub)
  
  # On associe un département à chacun des ménages à partir 
  # de probas de tirage correpsondantes aux parts des pop des départements.
  # (=> approximation de la répartition des ménages par la répartition de la pop)
  # Ainsi tous les individus d'un ménage sobnt dans le même département.
  prob_tirage_arrdts <- pop_arrondissements %>% group_by(REG, DEP, ARR) %>% 
    summarise(p = PMUN / sum(pop_arrondissements$PMUN), .groups="drop") 
  
  lfs_hh_arr <- lfs_micro_fr_2023 %>% 
    select(IDENT) %>% 
    unique() %>% 
    mutate(
      ARR = sample(
        prob_tirage_arrdts$ARR, 
        size = n(),
        replace = TRUE, 
        prob = prob_tirage_arrdts$p
      )
    ) %>% 
    left_join(prob_tirage_arrdts %>% select(DEP, REG, ARR), by = "ARR")
  
  lfs_micro_fr_2023 <- lfs_micro_fr_2023 %>% 
    left_join(lfs_hh_arr, by = "IDENT") %>% 
    select(
      REG, DEP, ARR, SEXE, AGE, AGE6, ACTEU, DIP7, 
      IDENT, PCS1Q, ANCCHOM
    ) 
  
  # Extrait d'un échantillon de ménages par département
  select_hh <- lfs_micro_fr_2023 %>% 
    select(DEP, IDENT) %>% 
    unique() %>% 
    group_by(DEP) %>% 
    slice_sample(prop = taux_echantillon) %>% 
    ungroup() %>% 
    select(IDENT) %>% 
    mutate(HHID = 1:n()) 
  
  lfs_2023 <- lfs_micro_fr_2023 %>% 
    filter(IDENT %in% select_hh$IDENT) %>%
    left_join(select_hh)
  
  # Ajout de variables au niveau ménage
  # Variables au niveau ménages (choix arbitraires)
  lfs_2023 <- lfs_2023 %>% 
    select(-IDENT) %>% 
    group_by(HHID) %>% 
    mutate(
      HH_TAILLE = n(),
      HH_AGE = max(AGE), # Age de la personne la plus âgée du ménage
      HH_DIP = DIP7[AGE == max(AGE)][1], #Diplôme de la personne la plus âgée
      HH_PCS = PCS1Q[AGE == max(AGE)][1] #Diplôme de la personne la plus âgée
    ) %>%
    ungroup()
  
  # Formatage final
  lfs_2023 <- lfs_2023 %>% 
    # Valeurs manquantes => codée en 99
    mutate( across( everything(), ~ifelse(is.na(.), 99, .))) %>% 
    mutate( across( c(-HHID, -AGE), as.factor) ) %>% 
    # Une variable binaire (chômage oui/non)
    mutate(IS_CHOM = as.numeric(ACTEU == 2))
  
  tx_chom_s <- sum(lfs_2023$ACTEU == 2)/sum(lfs_2023$ACTEU != 3)
  
  cat("taux de chômage national estimé à partir des données: ", tx_chom_s, " \n")
  
  data.table::fwrite(lfs_2023, file = filename)
  rm(select_hh, lfs_micro_fr_2023, ages, lfs_hh_arr, taux_echantillon, filename)
}
