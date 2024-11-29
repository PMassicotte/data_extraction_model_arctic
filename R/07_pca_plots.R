make_pca_plot <- function(pca, pca_df, file_pca) {
  # Get the cluster info
  clust <- read_lines(file_pca, n_max = 1L) |>
    str_split(stringr::fixed(","), simplify = TRUE)

  clust <- clust[3:length(clust)]

  lut <- c("4" = "A", "5" = "B", "6" = "C")
  clust <- as.vector(lut[clust])

  pca_summary <- summary(pca)
  explained_variance <- pca_summary[["importance"]][2L, ]
  percent_explained_variance <- round(explained_variance * 100L, digits = 1L)

  # scale the variable coordinates
  var <- facto_summarize(
    pca,
    element = "var",
    result = c("coord", "contrib", "cos2")
  )

  colnames(var)[2:3] <- c("x", "y")
  pca_ind <- get_pca_ind(pca)
  ind <- data.frame(pca_ind$coord[, drop = FALSE], stringsAsFactors = TRUE)
  colnames(ind) <- c("x", "y")

  r <- min(
    (max(ind[, "x"]) - min(ind[, "x"]) / (max(var[, "x"]) - min(var[, "x"]))),
    (max(ind[, "y"]) - min(ind[, "y"]) / (max(var[, "y"]) - min(var[, "y"])))
  )

  ind_coords <- get_pca(pca, element = "ind")
  var_coords <- get_pca(pca, element = "var")

  df_ind <- ind_coords$coord |>
    as.data.frame() |>
    rownames_to_column("site") |>
    as_tibble() |>
    janitor::clean_names() |>
    left_join(pca_df) |>
    mutate(cluster_site = factor(cluster_site))

  df_var <- var_coords$coord |>
    as.data.frame() |>
    rownames_to_column("variable") |>
    as_tibble() |>
    janitor::clean_names() |>
    mutate(across(-variable, \(x) x * r * 0.7)) |>
    mutate(var_cluster = clust, .after = 1L)

  set.seed(1234L)

  p1 <- df_ind |>
    ggplot(aes(x = dim_1, y = dim_2, color = cluster_site)) +
    geom_point(size = 3L) +
    geom_text_repel(aes(label = site), box.padding = 0.7, show.legend = FALSE) +
    paletteer::scale_color_paletteer_d("khroma::highcontrast") +
    labs(
      x = glue("PC1 ({percent_explained_variance[[1L]]}%)"),
      y = glue("PC2 ({percent_explained_variance[[2L]]}%)"),
      color = "Cluster\nsite"
    ) +
    new_scale_color() +
    geom_point(
      data = df_var,
      aes(x = dim_1, y = dim_2, color = "Variables"),
      size = 3L,
      shape = 17L,
      inherit.aes = FALSE
    ) +
    scale_color_manual("", values = list("Variables" = "grey60")) +
    geom_vline(xintercept = 0L, lty = 2L, color = "grey60") +
    geom_hline(yintercept = 0L, lty = 2L, color = "grey60") +
    theme(
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      panel.border = element_blank(),
      axis.text = element_text(size = 12L, face = "bold"),
      axis.title = element_text(size = 14L, face = "bold"),
      legend.text = element_text(size = 12L),
      legend.title = element_text(size = 14L)
    )

  p2 <- df_var |>
    ggplot(aes(x = dim_1, y = dim_2, color = var_cluster)) +
    geom_point(size = 3L, shape = 17L) +
    geom_text_repel(
      data = df_var,
      aes(x = dim_1, y = dim_2, label = variable, color = var_cluster),
      box.padding = 0.6,
      point.padding = 0.8,
      inherit.aes = FALSE,
      show.legend = FALSE
    ) +
    geom_vline(xintercept = 0L, lty = 2L, color = "grey60") +
    geom_hline(yintercept = 0L, lty = 2L, color = "grey60") +
    paletteer::scale_color_paletteer_d("trekcolors::starfleet") +
    labs(
      x = glue("PC1 ({percent_explained_variance[[1L]]}%)"),
      y = glue("PC2 ({percent_explained_variance[[2L]]}%)"),
      color = "Cluster\nvariable"
    ) +
    theme(
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      panel.border = element_blank(),
      axis.text = element_text(size = 12L, face = "bold"),
      axis.title = element_text(size = 14L, face = "bold"),
      legend.text = element_text(size = 12L),
      legend.title = element_text(size = 14L)
    )

  p <- p1 / p2 +
    plot_annotation(tag_levels = "a") &
    theme(plot.tag = element_text(size = 16L, face = "bold"))

  ggsave(
    fs::path("graphs", "pca.png"),
    width = 8L,
    height = 12L,
    dpi = 300L
  )
}
