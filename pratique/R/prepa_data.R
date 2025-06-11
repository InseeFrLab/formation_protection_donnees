# Téléchargement du fichier individuel de l'EEC 
options(timeout = 6000)
download.file(
  destfile = "data/lfs_micro_fr_2023.zip",
  url = "https://www.insee.fr/fr/statistiques/fichier/8241122/FD_csv_EEC23.zip"
)
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
str(lfs_micro_fr_2023)
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
    IDENT, PCS1Q, ANCCHOM, EXTRIAN) 

select_hh <- lfs_micro_fr_2023 %>% 
  select(DEP, IDENT) %>% 
  unique() %>% 
  group_by(DEP) %>% 
  slice_sample(prop = 0.1) %>% 
  ungroup() %>% 
  select(IDENT) %>% 
  mutate(HHID = 1:n())

lfs_2023 <- lfs_micro_fr_2023 %>% 
  filter(IDENT %in% select_hh$IDENT) %>%
  left_join(select_hh) %>% 
  select( -IDENT) %>% 
  mutate(POIDS = EXTRIAN * 10) %>% 
  select(-EXTRIAN) %>% 
  mutate(
    across(
      -POIDS,
      ~ifelse(is.na(.), 99, .)
    )
  ) %>% 
  mutate(
    across(
      c(-POIDS, -HHID),
      as.factor
    )
  )
  
# sum(lfs_2023$POIDS)
# sum(lfs_micro_fr_2023$EXTRIAN)

# data.table::fwrite(lfs_2023, file="data/lfs_2023_extract.csv")