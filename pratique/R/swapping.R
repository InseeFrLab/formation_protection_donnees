# Swapping avec sdcMicro

str(lfs_2023)

lfs_2023_pr_swap <- lfs_2023 %>% 
  mutate(across(-POIDS, as.integer)) %>% 
  mutate(
    REG = floor(DEP / 10),
    ID = 1:n()
  ) %>% 
  group_by(HHID) %>% 
  mutate(TAILLE = n()) %>% 
  ungroup() %>% 
  data.table::as.data.table()

risk_variables <- c("AGE6","SEXE","ACTEU")
hierarchy <- c("REG", "DEP")
similar <- c("DIP7")
carry_along <- NULL
k_anonymity <- 1
swaprate <- .05


hid <- "ID" # swapping d'individus

lfs_swapped <- recordSwap(
  data = lfs_2023_pr_swap,
  hid = hid,
  hierarchy = hierarchy,
  similar = similar,
  risk_variables = risk_variables,
  carry_along = carry_along,
  k_anonymity = k_anonymity,
  swaprate = swaprate,
  return_swapped_id = TRUE,
  seed = 123456
)

lfs_swapped %>% summarise(mean(ID != ID_swapped)) #5%
lfs_swapped %>% group_by(REG) %>%
  summarise(mean(ID != ID_swapped)) #5%

hid <- "HHID" # swapping de ménages
similar <- "TAILLE"

lfs_swapped_hh <- recordSwap(
  data = lfs_2023_pr_swap,
  hid = hid,
  hierarchy = hierarchy,
  similar = similar,
  risk_variables = risk_variables,
  carry_along = carry_along,
  k_anonymity = k_anonymity,
  swaprate = swaprate,
  return_swapped_id = TRUE,
  seed = 123456
)

lfs_swapped_hh %>% summarise(mean(HHID != HHID_swapped)) #6.2 des ménages
lfs_swapped_hh %>% filter(HHID != HHID_swapped) %>%
  summarise(n()/nrow(lfs_swapped_hh)*100) #6.2% des individus (les ménages swappés sont de même taille)
lfs_swapped_hh %>% filter(HHID != HHID_swapped) %>%
  summarise(mean(TAILLE))

