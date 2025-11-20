# 01_data_prep.R
library(tidyverse)

# BACA DATA SECARA RELATIF (WAJIB untuk GitHub + shinyapps)
df <- read_csv("data/wholesale_customers.csv")

summary(df)
colSums(is.na(df))

num_vars <- df %>% select(where(is.numeric))
df_scaled <- num_vars %>% scale() %>% as.data.frame()
rownames(df_scaled) <- NULL

df_final <- bind_cols(df %>% select(where(~!is.numeric(.))), df_scaled)

# Pastikan folder data/ ada
dir.create("data", showWarnings = FALSE)

write_csv(df_final, "data/prepared_data.csv")
