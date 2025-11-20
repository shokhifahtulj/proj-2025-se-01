# 03_clustering.R
library(tidyverse)
library(factoextra)
library(cluster)

num <- read_csv("data/prepared_data.csv") %>% select(where(is.numeric))

# Elbow
fviz_nbclust(num, kmeans, method = "wss") + labs(subtitle = "Elbow method")

# Silhouette
fviz_nbclust(num, kmeans, method = "silhouette")

# Gap stat (memerlukan waktu)
library(cluster)
set.seed(123)
gap_stat <- clusGap(num, FUN = kmeans, nstart = 25, K.max = 10, B = 50)
fviz_gap_stat(gap_stat)

# contoh run kmeans dengan k = 3
set.seed(123)
k <- 3
km.res <- kmeans(num, centers = k, nstart = 25)

# visualisasi (PCA)
library(ggplot2)
library(factoextra)
fviz_cluster(km.res, data = num)

# simpan result
clustered <- num %>% mutate(cluster = factor(km.res$cluster))
write_csv(clustered, "data/clustered.csv")