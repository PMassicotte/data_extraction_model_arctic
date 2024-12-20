sites_clustering <- function(pca) {
  # Results for sites
  res_ind <- get_pca_ind(pca)
  res_ind_coord <- as.data.frame(res_ind[["coord"]])
  res_ind[["contrib"]]
  res_ind[["cos2"]]
  res_ind_coord[["Station"]] <- rownames(res_ind_coord)
  pca_points <- res_ind_coord

  # hierarchical cluster analysis for sites
  dist_matrix <- dist(pca_points, method = "euclidean")
  hclust_site_result <- hclust(dist_matrix, method = "ward.D2")

  groups <- cutree(hclust_site_result, k = 3L)
  pca_points[["cluster"]] <- as.factor(groups)

  list(
    hclust_site_result = hclust_site_result,
    groups = groups,
    pca_points = pca_points
  )
}
