make_corr_plots <- function(extracted_data, file_plot) {
  col_keep <- c(4L, 5L, 8L, 9L, 10L, 12:16, 19L, 21L, 23L, 25:34)

  df <- extracted_data |>
    select(-(1:4)) |>
    select(data_plastic_concentration_ng_l, all_of(col_keep)) |>
    drop_na() |>
    rename_with(\(s) str_remove(s, "cmems_mod.*m_"), everything()) |>
    janitor::clean_names() |>
    rename_with(\(s) str_remove(s, stringr::fixed("_depth_0")), everything())

  df

  # Log variables to further calculate correlation with plastic concentration
  df_log <- recipe(~., data = df) |>
    step_log(all_numeric()) |>
    prep() |>
    juice()

  # Select all correlations above 0.3
  variables <- df_log |>
    correlate() |>
    focus(data_plastic_concentration_ng_l) |>
    filter(
      abs(data_plastic_concentration_ng_l) >= 0.3,
      abs(data_plastic_concentration_ng_l) < 1L
    ) |>
    pull(term)

  # Select the variables from the original (not transformed) data
  df_subset <- df |>
    select(data_plastic_concentration_ng_l, any_of(variables))

  p1 <- df_subset |>
    ggplot(aes(x = expc, y = data_plastic_concentration_ng_l)) +
    geom_point() +
    geom_smooth(method = "lm") +
    scale_x_log10() +
    annotation_logticks(sides = "b", linewidth = 0.2) +
    stat_correlation(
      mapping = use_label("R", "t", "P", "n"),
      label.x = "right",
      label.y = "bottom"
    ) +
    labs(
      x = parse(text = "Sinking~mole~flux~POC~(mol~m^{-2}~d^{-1})"),
      y = parse(text = "Plastic~concentration~(ng~L^{ -1 })")
    )

  p2 <- df_subset |>
    ggplot(aes(x = nppv, y = data_plastic_concentration_ng_l)) +
    geom_point() +
    geom_smooth(method = "lm") +
    scale_x_log10() +
    stat_correlation(
      mapping = use_label("R", "t", "P", "n"),
      label.x = "right",
      label.y = "bottom"
    ) +
    annotation_logticks(sides = "b", linewidth = 0.2) +
    labs(
      x = parse(text = "Net~primary~production~(mg~m^{-3}~d^{-1})"),
      y = parse(text = "Plastic~concentration~(ng~L^{ -1L })")
    )

  p3 <- df_subset |>
    ggplot(aes(x = phyc, y = data_plastic_concentration_ng_l)) +
    geom_point() +
    geom_smooth(method = "lm") +
    scale_x_log10() +
    stat_correlation(
      mapping = use_label("R", "t", "P", "n"),
      label.x = "right",
      label.y = "bottom"
    ) +
    annotation_logticks(sides = "b", linewidth = 0.2) +
    labs(
      x = parse(text = "Mole~concentration~phytoplankton~(mmol~m^{-3})"),
      y = parse(text = "Plastic~concentration~(ng~L^{ -1L })")
    )

  p4 <- df_subset |>
    ggplot(aes(x = zooc, y = data_plastic_concentration_ng_l)) +
    geom_point() +
    geom_smooth(method = "lm") +
    scale_x_log10() +
    stat_correlation(
      mapping = use_label("R", "t", "P", "n"),
      label.x = "right",
      label.y = "bottom"
    ) +
    annotation_logticks(sides = "b", linewidth = 0.2) +
    labs(
      x = parse(text = "Mole~concentration~zooplankton~(mmol~m^{-3})"),
      y = parse(text = "Plastic~concentration~(ng~L^{ -1L })")
    )

  p <- p1 + p2 + p3 + p4 +
    plot_annotation(tag_levels = "A")

  ggsave(
    file_plot,
    device = cairo_pdf,
    width = 9L,
    height = 7L
  )

  p
}
