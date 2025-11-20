# 02_eda.R
library(tidyverse)
library(ggplot2)
library(corrplot)

df <- read_csv("data/prepared_data.csv")
num <- df %>% select(where(is.numeric))

# histogram
num %>% gather(var, val) %>% ggplot(aes(val)) + geom_histogram(bins=30) + facet_wrap(~var, scales='free')

# correlation
corr_mat <- cor(num)
corrplot::corrplot(corr_mat, method='color')

# summary table
summary(num)