extract <- function(raster_path, station) {
  r <- rast(raster_path)

  stations_vec <- vect(
    station,
    geom = c("longitude", "latitude"),
    crs = "EPSG:4326"
  ) |>
    project(r)

  extracted_nutrients <- terra::extract(r, stations_vec, bind = FALSE) |>
    as_tibble()
}

batch_extract <- function(stations, downloaded_files) {
  raster_files <- downloaded_files |>
    enframe(name = NULL, value = "path") |>
    mutate(date = str_extract(path, "\\d{4}-\\d{2}-\\d{2}"), .before = 1L) |>
    mutate(date = ymd(date)) |>
    arrange(date)

  stations_nested <- stations |>
    arrange(sampling_date) |>
    left_join(
      raster_files,
      by = join_by(sampling_date == date),
      relationship = "many-to-many"
    ) |>
    nest(.by = c(sampling_date, path), .key = "data") |>
    as_tibble()

  extracted_data <- stations_nested |>
    mutate(raster_data = map2(path, data, extract, .progress = TRUE))

  res <- extracted_data |>
    mutate(
      data_type = str_extract(path, "cmems.*P1D-m"),
      .after = sampling_date
    ) |>
    select(-path) |>
    pivot_wider(names_from = data_type, values_from = raster_data) |>
    select(1:5) |>
    unnest(everything(), names_sep = "_")

  res
}
