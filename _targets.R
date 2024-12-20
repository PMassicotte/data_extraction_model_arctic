library(targets)
library(tarchetypes)
library(tidyverse)
library(ggpmthemes)
library(glue)
library(here)
library(readxl)
library(terra)
library(tidyterra)
library(fs)
library(furrr)
library(cli)
library(tidymodels)
library(corrr)
library(patchwork)
library(ggpmisc)
library(factoextra)
library(ggrepel)
library(ggnewscale)

theme_set(theme_poppins(base_size = 10L, base_family = "Arial"))
theme_update(
  panel.border = element_blank(),
  axis.ticks = element_blank(),
  strip.background = element_blank(),
  strip.text = element_text(size = 12L, face = "bold"),
  plot.title = element_text(size = 14L)
)

# Set up parallel processing
plan(multicore(workers = 12L))

tar_source()

tar_option_set(
  format = tar_format_nanoparquet()
)

list(
  tar_file(
    station_file,
    fs::path("data", "raw", "stations_huiwen_updated.xlsx")
  ),
  tar_target(stations, clean_stations(station_file)),
  tar_file(
    downloaded_files,
    batch_download(stations, fs::path("data", "raw", "copernicus"))
  ),
  tar_target(extracted_data, batch_extract(stations, downloaded_files)),
  tar_file(
    extracted_data_file,
    write_csv_file(
      extracted_data,
      fs::path("data", "clean", "extracted_nutrients.csv")
    )
  ),
  tar_target(
    corr_plot,
    make_corr_plots(
      extracted_data,
      fs::path("graphs", "correlations_plots.pdf")
    ),
    format = "rds"
  ),
  tar_file(
    file_pca,
    fs::path("data", "raw", "Environment variables_2022&2023_withcluster.csv")
  ),
  tar_target(pca_df, clean_pca_data(file_pca)),
  tar_target(pca, make_pca(pca_df), format = "rds"),
  tar_target(
    env_clusters,
    env_variables_clustering(pca),
    format = "rds"
  ),
  tar_target(sites_clusters, sites_clustering(pca), format = "rds"),
  tar_target(pca_plot, make_pca_plot(pca, pca_df, file_pca), format = "rds")
)
