clean_stations <- function(file) {
  stations <- read_excel(file) |>
    select(-1L) |>
    janitor::clean_names() |>
    filter(!str_detect(longitude, "^[A-Za-z]")) |>
    type_convert() |>
    mutate(sampling_date = str_match(site, "\\d{8}")[, 1L], .after = site) |>
    mutate(sampling_date = ymd(sampling_date))

  stations
}
