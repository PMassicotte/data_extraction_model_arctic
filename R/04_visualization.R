# Just to check why some extracted values are NA.
# Looks like that some stations are on the land or inside inland river at a
# spatial scale too fine for the raster data.

# stations_vec <- stations |>
#   vect(geom = c("longitude", "latitude"), crs = "EPSG:4326")
#
# dest_csr <- crsuggest::suggest_crs(stations_vec) |>
#   slice(1L) |>
#   pull(crs_proj4)
#
# svalbard <- vect(here::here("data", "raw", "svalbard_bbox.geojson")) |>
#   project(dest_csr)
#
# r <- rast("data/raw/copernicus/cmems_mod_arc_phy_my_topaz4_P1D-m_multi-vars_131.38W-57.38E_77.12N-89.88N_0.00m_2023-07-31.nc")
#
# stations_vec |>
#   ggplot() +
#   geom_spatraster(data = r, aes(fill = `siconc`)) +
#   geom_spatvector(color = "red") +
#   scale_fill_viridis_c(na.value = NA) +
#   coord_sf(crs = dest_csr) +
#   facet_wrap(~lyr)
#
# extracted_nutrients_clean <- extracted_nutrients |>
#   as_tibble() |>
#   janitor::clean_names()
#
# extracted_nutrients_clean
#
# extracted_nutrients_clean |>
#   write_csv(here::here("data", "clean", "extracted_nutrients.csv"))
