env_variables_clustering <- function(pca) {
  res_var <- get_pca_var(pca)
  res_var_coord <- as.data.frame(res_var[["coord"]])
  res_var[["contrib"]]
  res_var[["cos2"]]
  vectors <- as.data.frame(res_var[["coord"]])

  # hierarchical cluster analysis for variables
  dist_matrix_env <- dist(vectors, method = "euclidean")
  hclust_env_result <- hclust(dist_matrix_env, method = "ward.D2")
  env_groups <- cutree(hclust_env_result, k = 3L)
  vectors[["cluster"]] <- as.factor(env_groups)

  vectors[["cluster"]] <- as.numeric(vectors[["cluster"]])
  vectors <- mutate(vectors, cluster_b = (4L + cluster))
  vectors[["cluster_b"]] <- as.factor(vectors[["cluster_b"]])

  list(
    hclust_env_result = hclust_env_result,
    vectors = vectors,
    env_groups = env_groups
  )
}
