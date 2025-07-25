# Appliquer PRAM
# Le programme fait suite aux travaux réalisés dans 01_mesurer_risque.R

## Première tentative --------
set.seed(12345)

pram_1 <- pram(
  lfs_2023,
  variables = "ACTEU",
  pd = 0.8
)
str(pram_1) #liste

attributes(pram_1) #résumé 

# Récupérer les données
data_pram_1 <- do.call(cbind, pram_1) %>% data.frame()

# invariance globale
data_pram_1 %>% 
  summarise(mean(ACTEU == ACTEU_pram))

# Comparaison
data_pram_1 %>% 
  count(ACTEU, ACTEU_pram) %>% 
  group_by(ACTEU) %>% 
  mutate(part = n/sum(n)*100) %>% 
  select(-n) %>% 
  tidyr::pivot_wider(
    names_from = ACTEU_pram, values_from = part, names_prefix = "PRAM_"
  )

# Le taux de chômage dans l'échantillon est-il biaisé ?
data_pram_1 %>% 
  summarise(
    tc = sum(ACTEU == 2)/sum(ACTEU %in% 1:2) *100,
    tc_pram = sum(ACTEU_pram == 2)/sum(ACTEU_pram %in% 1:2) *100
  )


## Seconde tentative tentative --------
pram_2 <- pram(
  lfs_2023,
  variables = "ACTEU",
  strata_variables = "AGE6",
  pd = 0.8
)

attributes(pram_2) #résumé 

# Récupérer les données
data_pram_2 <- do.call(cbind, pram_2) %>% data.frame()

# invariance globale
data_pram_2 %>% 
  summarise(mean(ACTEU == ACTEU_pram))

# Comparaison marice de transition et observations
attributes(pram_2)$pram_params$ACTEU$Rs

data_pram_2 %>% 
  count(ACTEU, ACTEU_pram) %>% 
  group_by(ACTEU) %>% 
  mutate(part = n/sum(n)*100) %>% 
  select(-n) %>% 
  tidyr::pivot_wider(
    names_from = ACTEU_pram, values_from = part, names_prefix = "PRAM_"
  )


data_pram_2 %>% 
  summarise(
    tc = sum(ACTEU == 2)/sum(ACTEU %in% 1:2) *100,
    tc_pram = sum(ACTEU_pram == 2)/sum(ACTEU_pram %in% 1:2) *100
  )


## Et si on choisissait notre propre  matrice de transition ? -----

mat <- matrix(
  c(0.7,0.2,0.1,
    0.3, 0.6, 0.1,
    0.1, 0.1, 0.8
  ),
  nrow = 3,
  byrow = TRUE
)
row.names(mat) <- colnames(mat) <- levels(lfs_2023$ACTEU)

pram_3 <- pram(
  lfs_2023,
  variables = "ACTEU",
  pd = mat,
  alpha = NA
)

attributes(pram_3)$pram_params$ACTEU$Rs

data_pram_3 <- do.call(cbind, pram_3) %>% data.frame()

data_pram_3 %>% 
  count(ACTEU, ACTEU_pram) %>% 
  group_by(ACTEU) %>% 
  mutate(part = n/sum(n)*100) %>% 
  select(-n) %>% 
  tidyr::pivot_wider(
    names_from = ACTEU_pram, values_from = part, names_prefix = "PRAM_"
  )

# ATTENTION ce type de PRAM n'est pas invariant: les estimatons sont biaisées
# Calcul du taux de chômage
data_pram_3 %>% 
  summarise(
    tc = sum(ACTEU == 2)/sum(ACTEU %in% 1:2) *100,
    tc_pram = sum(ACTEU_pram == 2)/sum(ACTEU_pram %in% 1:2) *100
  )

## PRAM Invariant  -----
# Par défaut, la fonction pram() calcule un pram dit invariant 
# pour empêcher les 

pram_4 <- pram(
  lfs_2023,
  variables = "ACTEU",
  pd = 0.5,
  alpha = 0.8
)

attributes(pram_4)$pram_params$ACTEU$Rs

data_pram_4 <- do.call(cbind, pram_4) %>% data.frame()

data_pram_4 %>% 
  count(ACTEU, ACTEU_pram) %>% 
  group_by(ACTEU) %>% 
  mutate(part = n/sum(n)*100) %>% 
  select(-n) %>% 
  tidyr::pivot_wider(
    names_from = ACTEU_pram, values_from = part, names_prefix = "PRAM_"
  )

# Calcul du taux de chômage
data_pram_4 %>% 
  summarise(
    tc = sum(ACTEU == 2)/sum(ACTEU %in% 1:2) *100,
    tc_pram = sum(ACTEU_pram == 2)/sum(ACTEU_pram %in% 1:2) *100
  )


## Application sur notre objet sdcMicro -------

pram_sdc  <- pram(sdc_object1, variables = NULL, strata_variables = NULL)
str(pram_sdc,1)

pram_sdc@origData %>%
  group_by(ACTEU) %>%
  count()

pram_sdc@manipPramVars %>%
  group_by(ACTEU) %>%
  count()

# Comparaison:
prop.table(
  table(
    pram_sdc@manipPramVars$ACTEU,
    pram_sdc@origData$ACTEU
  ), margin = 1
)

#  Les paramètres utilisés par défaut:
sdc_object1@pram
pram_sdc@pram

# La matrice de transition
pram_sdc@pram$params$ACTEU$Rs

# Transitions
pram_sdc@pram$transitions$ACTEU

