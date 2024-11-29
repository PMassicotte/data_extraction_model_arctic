clean_pca_data <- function(file_pca) {
  df <- read_csv(
    file_pca,
    skip = 1L
  ) |>
    janitor::clean_names() |>
    drop_na()

  df <- df |>
    mutate(across(where(is.character), str_trim))

  df
}

make_pca <- function(pca_df) {
  df_pca <- pca_df |>
    select(-c(site, cluster_site)) |>
    as.data.frame()

  rownames(df_pca) <- pca_df[["site"]]

  pca <- prcomp(df_pca, scale = TRUE, center = TRUE)

  pca
}
