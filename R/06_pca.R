make_pca <- function(file) {
  df <- read_csv(
    file,
    skip = 1L
  ) |>
    janitor::clean_names() |>
    drop_na()

  clust <- read_lines(file, n_max = 1L) |>
    str_split(stringr::fixed(","), simplify = TRUE)

  clust <- clust[3:length(clust)]

  lut <- c("4" = "A", "5" = "B", "6" = "C")

  clust <- as.vector(lut[clust])

  df_pca <- df |>
    select(-c(site, cluster_site)) |>
    scale(center = TRUE, scale = TRUE) |>
    as_tibble()

  rownames(df_pca) <- df[["site"]]

  pp <- prcomp(df_pca)

  p <- fviz_pca_biplot(
    pp,
    repel = TRUE,
    col.var = clust,
    col.ind = "#696969",
    pointshape = 21L,
    pointsize = rep(0.5, nrow(df)),
    fill.ind = factor(df[["cluster_site"]]),
    title = "",
    arrowsize = 0.25
  ) +
    paletteer::scale_fill_paletteer_d("ggthemes::wsj_rgby") +
    paletteer::scale_color_paletteer_d("nbapalettes::bulls_city") +
    guides(
      color = guide_legend(override.aes = list(label = "")),
      size = "none",
      fill = guide_legend(override.aes = list(size = 3L))
    ) +
    labs(
      fill = "Site\nclusters",
      color = "Variable\nclusters"
    ) +
    theme(axis.ticks = element_blank())

  ggsave(
    fs::path("graphs", "pca.pdf"),
    device = cairo_pdf,
    width = 8L,
    height = 8L
  )

  p
}
