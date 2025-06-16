# Téléchargement du fichier individuel de l'EEC 

filename <- "data/lfs_2023.csv"

taux_echantillon <- 0.1

if(!dir.exists("data/")) dir.create("data/")

if(file.exists(filename)){

  lfs_2023 <- data.table::fread(filename) %>%
    mutate(
      across(
        c(-POIDS, -HHID, -AGE),
        as.factor
      )
    )
  
}else{

  options(timeout = 6000)
  download.file(
    destfile = "data/lfs_micro_fr_2023.zip",
    url = "https://www.insee.fr/fr/statistiques/fichier/8241122/FD_csv_EEC23.zip"
  )
  dir.create("data/")
  unzip(zipfile = "data/lfs_micro_fr_2023.zip", exdir = "data")


  lfs_micro_fr_2023 = read.csv2(
    "data/FD_csv_EEC23.csv",
    header = TRUE,
    sep = ";",
    quote = "\"",
    dec = ".",
    fill = TRUE, 
    comment.char = ""
  )
  # str(lfs_micro_fr_2023)
  # Documentation du fichier
  # https://www.insee.fr/fr/statistiques/8241122#dictionnaire

  # Reconstruction d'une variable d'âge

  set.seed(1234)
  ages <- tibble(
    AGE6 = sort(unique(lfs_micro_fr_2023$AGE6))
  ) %>% 
    mutate(
      ages_ub = dplyr::lead(AGE6-1, default = 120)
    )

  lfs_micro_fr_2023 <- lfs_micro_fr_2023 %>% 
    left_join(
      ages, by = "AGE6" 
    ) %>% 
    # On conserve uniquement les ménages dont la personne est âgée entre 15 et 89 ans
    filter(CHAMP_M_15_89 == 1) %>%
    mutate(
      AGE = round(runif(n(), min = AGE6, max = ages_ub))
    ) %>% 
    # tirage d'une géographie aléatoire
    # Les individus d'un même ménage ont la même géographie
    group_by(IDENT) %>% 
    mutate(
      DEP = sample(1:97, size = 1, replace = TRUE)
    ) %>% 
    select(-ages_ub) %>% 
    as.data.frame() %>% 
    select(
      DEP, SEXE, AGE, AGE6, ACTEU, DIP7, 
      IDENT, PCS1Q, ANCCHOM, EXTRIAN
    ) 

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
    left_join(select_hh) %>% 
    select( -IDENT) %>% 
    mutate(POIDS = EXTRIAN / taux_echantillon) %>% 
    select(-EXTRIAN) %>% 
    # Valeurs manquantes => codée en 99
    mutate(
      across(
        -POIDS,
        ~ifelse(is.na(.), 99, .)
      )
    ) %>% 
    mutate(
      across(
        c(-POIDS, -HHID, -AGE),
        as.factor
      )
    ) %>%
    mutate(IS_CHOM = as.numeric(ACTEU == 2)) %>%
    # Variables au niveau ménages (choix arbitraires)
    group_by(HHID) %>% 
    mutate(
      HH_TAILLE = n(),
      HH_AGE = max(AGE), # Age de la personne la plus âgée du ménage
      HH_DIP = DIP7[AGE == max(AGE)][1], #Diplôme de la personne la plus âgée
      HH_PCS = PCS1Q[AGE == max(AGE)][1] #Diplôme de la personne la plus âgée
      ) %>%
    ungroup()

  data.table::fwrite(lfs_2023, file = filename)
  rm(select_hh, lfs_micro_fr_2023, ages)
}
