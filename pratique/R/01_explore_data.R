library(dplyr)

source("exercices/microdonnees/00_telechargement_donnees_eec.R")

str(lfs_2023)
summary(lfs_2023)

dim(lfs_2023)

# Variables 
colnames(lfs_micro_arm_2020)
colnames(lfs_micro_fr_2020)

# Counts:
#Individuals (sampled)
lfs_micro_arm_2020 %>%
  count()
#(population)
lfs_micro_arm_2020 %>%
  count(wt = WeightsCalib_year)

#IDmem : identify the member of the household
lfs_micro_arm_2020 %>%
  select(IDmem) %>%
  unique() %>%
  nrow()

# Questionnaires
lfs_micro_arm_2020 %>%
  select(A1) %>%
  unique() %>%
  nrow()

# Number HH
lfs_micro_arm_2020 %>%
  select(A2) %>%
  unique() %>%
  nrow()

# How identify members of a same household ?
lfs_micro_arm_2020 %>%
  filter(A1 == 649) %>%
  select(IDmem, A1,A2,A6_Month,A7,A8, starts_with("Weights")) %>%
  View()

# Presence of identifiers: No

# Which potential key variables ?
# Sex : arm => B3; fr => SEXE
# Age : arm => B5+B6 = Date of birth (month + year); fr => AGE5 and AGE3
lfs_micro_arm_2020 %>%
  group_by(B6, B5) %>%
  count() %T>%
  print() %>%
  filter(n==1) %>%
  nrow()

lfs_micro_fr_2020 %>%
  group_by(AGE3, AGE5) %>%
  count()

# Geographical Area : 
# arm => A3 = Marz (equivalent of province), A5 = Urban/Rural class; 
lfs_micro_arm_2020 %>%
  group_by(A3, A5) %>%
  count()

# fr => CATAU2010R = like a urban vs rural categories; METRODOM = metropolitan france or overseas territories
lfs_micro_fr_2020 %>%
  group_by(METRODOM, CATAU2010R) %>%
  count()

# Marital Status : arm => B11; fr => absent but the type of household is displayed (TYPMEN7)
lfs_micro_arm_2020 %>%
  group_by(B11) %>%
  count()

lfs_micro_fr_2020 %>%
  group_by(TYPMEN7) %>%
  count()

# Occupation : arm => maybe ; fr => ACTEU6 
lfs_micro_arm_2020 %>%
  group_by(empj, emsj, iempj, iemsj, LU1_unemployed, LU2_combined_nomin, long_unemployed) %>%
  count()

# Diploma: arm => B7; fr => DIP11
lfs_micro_arm_2020 %>%
  group_by(B7) %>%
  count()

lfs_micro_fr_2020 %>%
  group_by(DIP11) %>%
  count()

#10: Bachelor's degree or higher
#11: Schools at Bachelor's degree level (example : Ingeneering schools)
#30: First two years at univeristy (Highschool +2)
#31: Diploma of superior technician (Highschool + 2)
#33: Paramedical or social diploma (Highschool +2) 
#41: Bachelor (diploma at the end of highschool)
#42: Technological/Professionnal Bachelor
#50: Certificate of professional competence (CAP + BEP)
#60: Basic
#70: Primary
#71: No diploma

# Potential Sensitive variables :
# arm => maybe E15 (income), C2 (nationality);
# fr => nationality (NFRRED);
lfs_micro_arm_2020 %>%
  group_by(E15) %>%
  count()

lfs_micro_arm_2020 %>%
  group_by(C2) %>%
  count()

lfs_micro_fr_2020 %>%
  group_by(NFRRED) %>%
  count()
#NFRRED : 1 = French by birth; 2 = French by acquisition; 3 = foreigner


# Conclusion:

#1- No identifiers in the tables
#2- Quasi-identifying variables (key variables) :
# arm => AGE, SEXE, Geographical Area (Marz), Marital Status, Diploma
# fr => AGE, SEXE, Geographical area, Type of Household, Diploma
#3- Potential Sensitive variables 
# arm => income, nationality, unemployment
# fr => nationality, unemployment






