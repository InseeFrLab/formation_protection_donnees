library(dplyr)
library(synthpop)

lfs_2023 <- data.table::fread(file="data/lfs_2023_extract.csv")

lfs_2023_pr_synth <- lfs_2023 %>% 
  mutate(
    REG = floor(as.numeric(DEP) / 10)
  ) %>% 
  select(-DEP, -HHID) %>% 
  mutate( across(c(-AGE, -POIDS), as.factor))
  

str(lfs_2023_pr_synth)

lfs_synth_1 <- syn(lfs_2023_pr_synth, method = "cart")
lfs_synth_2 <- syn(lfs_2023_pr_synth, method = "parametric")



compare(lfs_synth_1, lfs_2023_pr_synth, vars = "ACTEU") 
compare(lfs_synth_2, lfs_2023_pr_synth, vars = "ACTEU") 
compare(lfs_synth_1$syn %>% filter(ANCCHOM != 99), lfs_2023_pr_synth %>% filter(ANCCHOM != 99), vars = "ANCCHOM") 
compare(lfs_synth_2$syn %>% filter(ANCCHOM != 99), lfs_2023_pr_synth %>% filter(ANCCHOM != 99), vars = "ANCCHOM") 

# - Modeling and results comparison 
glm_orig <- glm(
  CHOM ~ SEXE + AGE + DIP7, 
  family = "binomial",
  data = lfs_2023_pr_synth %>% mutate(CHOM = ACTEU == 2)
)
summary(glm_orig)

glm_synth1 <- glm(
  CHOM ~ SEXE + AGE + DIP7, 
  family = "binomial",
  data = lfs_synth_1$syn %>% mutate(CHOM = ACTEU == 2)
)
summary(glm_synth1)

glm_synth2 <- glm(
  CHOM ~ SEXE + AGE + DIP7, 
  family = "binomial",
  data = lfs_synth_2$syn %>% mutate(CHOM = ACTEU == 2)
)
summary(glm_synth2)

compare(
  lfs_synth_1$syn %>% mutate(CHOM = ACTEU == 2), 
  lfs_2023_pr_synth %>% mutate(CHOM = ACTEU == 2)
)

library(DescTools)

CramerV(lfs_synth_1$syn$ACTEU, y = lfs_synth_1$syn$AGE6, conf.level = NA)
CramerV(lfs_synth_2$syn$ACTEU, y = lfs_synth_2$syn$AGE6, conf.level = NA)
CramerV(lfs_2023_pr_synth$ACTEU, y = lfs_2023_pr_synth$AGE6, conf.level = NA)


# Générer plusieurs jeux
lfs_synth_15 <- syn(lfs_2023_pr_synth, method = "cart", m=5)
lfs_synth_25 <- syn(lfs_2023_pr_synth, method = "parametric", m=5)


compare(lfs_synth_15, lfs_2023_pr_synth, vars = "ACTEU", msel = 1:5)
compare(lfs_synth_25, lfs_2023_pr_synth, vars = "ACTEU", msel = 1:5)

compare(
  lfs_synth_15, 
  lfs_2023_pr_synth,
  msel = 1:5
)

compare(
  lfs_synth_25, 
  lfs_2023_pr_synth,
  msel = 1:5
)
