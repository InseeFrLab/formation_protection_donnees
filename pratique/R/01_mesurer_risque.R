# Mesurer le risque
library(sdcMicro)
library(dplyr)
library(ggplot2)


key_vars <- c("DEP", "SEXE", "AGE", "DIP7")

sdc_object <- createSdcObj(
  dat=lfs_2023,
  keyVars=key_vars,
  hhId = "HHID",
  weightVar = "POIDS",
  sensibleVar = "ANCCHOM",
  pramVars = "ACTEU",
  seed = 20061789
)

str(sdc_object, max.level = 2)

# k-anonymat (par défaut k=2, 3 et 5)
print(sdc_object)

# Risque global
print(sdc_object, 'risk')

lfs_indiv_at_risk <- sdc_object@risk$individual %>%
  as_tibble()

lfs_indiv_at_risk %>%
  count(fk) %>% 
  mutate(part = n/sum(n)*100) %>%
  mutate(n_cum = cumsum(n), part_cum = cumsum(part))

# L'échantillon est 1-anonyme

key_vars1 <- c("DEP", "SEXE", "AGE6", "DIP7")

sdc_object1 <- createSdcObj(
  dat=lfs_2023,
  keyVars=key_vars1,
  hhId = "HHID",
  weightVar = "POIDS",
  sensibleVar = "ANCCHOM",
  pramVars = "ACTEU",
  seed = 20061789
)

lfs_indiv_at_risk1 <- sdc_object1@risk$individual %>%
  as_tibble()

lfs_indiv_at_risk1 %>%
  count(fk) %>% 
  mutate(part = n/sum(n)*100) %>%
  mutate(n_cum = cumsum(n), part_cum = cumsum(part))

# On a toujours un échantillon 1-anonyme mais le 
# nb d'individus à risquea bcp diminué !

# Combinaisons très problématiques (uniques dans l'échantillon)
lfs_2023 %>% 
  filter(lfs_indiv_at_risk1$fk < 2) %>%
  select(key_vars1)


# Y a t il des uniques dans la population ?
sum(lfs_indiv_at_risk$Fk < 2) #Aucun unique de population (avec clés originales)
sum(lfs_indiv_at_risk1$Fk < 2) #Aucun unique de population (avec clés revues)

min(lfs_indiv_at_risk$Fk) 
min(lfs_indiv_at_risk1$Fk)

# La mesure de risque proposée par sdcMicro
# Un faible nombre d'occurrences dans l'échantillon 
# est problématique car si nous savons qu'un individu est présent dans l'échantillon, 
# nous pouvons alors déduire tous ses autres attributs divulgués. Cependant, 
# la mesure de k-anonymat ne prend pas en compte le fait que nous travaillons
# avec un échantillon. 
  
# Existe-t-il un risque d'identifier un individu dans la 
# population à partir des données divulguées dans l'échantillon ?
# sdcMicro propose une estimation du risque d'identifier un individu au sein
# de la population à partir de l'échantillon donné.
print(sdc_object, "risk")
print(sdc_object1, "risk")

summary(lfs_indiv_at_risk$risk) #Risque individuel max 0.34
summary(lfs_indiv_at_risk1$risk)#Risque individuel max 0.12
# Le risque individuel peut être interprété par la 
# probabilité de ré-identifier un individu de la population 
# à partir d'un individu de l'échantillon.


lfs_indiv_at_risk %>%
  ggplot() +
  geom_histogram(aes(x = risk), binwidth = 0.005) +
  geom_vline(xintercept = 0.05, col = "orangered", linetype = "dashed") +
  scale_x_continuous("individual risk", breaks = seq(0,0.8,0.05), expand = c(0,0)) +
  ggtitle(
    label = "Individual risks distribution"
  )

# Risque vs comptage 
lfs_indiv_at_risk %>%
  ggplot() +
  geom_boxplot(aes(group=as.factor(fk), x = risk)) +
  scale_y_continuous("fk", labels = 1:11, breaks = seq(-0.333,0.4,0.0667), expand = c(0,0)) +
  ggtitle(
    label = "Risque individuel en fonction des fréquences dans l'échantillon"
  )

lfs_indiv_at_risk %>%
  bind_cols(
    lfs_2023 %>% 
      select(all_of(key_vars), POIDS)
  ) %>%
  filter(fk <=5) %>% 
  ggplot() +
  geom_point(aes(col = as.factor(fk), x=POIDS, y = risk), alpha = 0.65, size = 0.5) +
  scale_color_brewer("frequency count", type="qual", palette = 7) +
  ggtitle(
    label = "Individual risk as a function of Weights, by frequency counts",
    subtitle = "Only frequency counts <= 5 are drawn"
  )

# Lien entre risque empirique et risque mesuré par sdcMicro
# Pour les plus petits comptages, le risque sdcMicro 
# est surestimé par rapport au risque empirique 
lfs_indiv_at_risk %>%
  bind_cols(
    lfs_2023 %>% 
      select(all_of(key_vars1),POIDS)
  ) %>%
  mutate(ratio = fk/Fk, risk_emp = 1/Fk) %>% 
  ggplot() +
  geom_point(aes(x=risk_emp, y=risk)) +
  geom_abline(slope = 1, intercept = 0) +
  facet_wrap(~fk, scales = "free") +
  scale_x_continuous( "risque empirique 1/Fk") +
  scale_y_continuous( "risque sdcMicro") 
  #ggtitle(label = "Lien entre risque individuel mesuré par sdcMicro et le risque empirique")


# Appliquons une suppression locale

# sdc_object <- localSuppression(sdc_object, k=2, importance = NULL)
sdc_object1 <- localSuppression(sdc_object1, k=2, importance = NULL)
print(sdc_object1, "ls")
# Automatiquement le Département est choisie principalement pour 
# effectuer les suppressions 

# Si on souhaite que le département soit la variable la moins touchée
# on modifie le paramètre importance en associant une valeur 
# d'importance à chaque clé (plus faible est la valeur plus la valeur 
# est importante, moins la variable sera touchée.)

sdc_object1 <- undolast(sdc_object1) # pour défaire les suppressions
sdc_object1 <- localSuppression(sdc_object1, k=2, importance = 1:4)
print(sdc_object1, "ls")

sdc_object1 <- undolast(sdc_object1) # pour défaire les suppressions

