variables <- list(
  "cmems_mod_arc_phy_my_topaz4_P1D-m" = c(
    "bottomT", "mlotst", "model_depth", "siconc", "sisnthick", "sithick", "so",
    "stfbaro", "thetao", "vxo", "vxsi", "vyo", "vysi", "zos"
  ),
  "cmems_mod_arc_bgc_anfc_ecosmo_P1D-m" = c(
    "chl", "dissic", "expc", "kd", "model_depth", "no3", "nppv", "o2", "ph",
    "phyc", "po4", "si", "spco2", "zooc"
  ),
  "cmems_mod_arc_phy_anfc_6km_detided_P1D-m" = c(
    "bottomT", "mlotst", "model_depth", "siage", "sialb", "siconc", "siconc_fy",
    "sisnthick", "sithick", "so", "stfbaro", "thetao", "vxo", "vxsi", "vyo",
    "vysi", "wo", "zos"
  )
)

check_copernicusmarine <- function() {
  result <- system("command -v copernicusmarine", intern = TRUE)

  if (length(result) == 0L) {
    cli::cli_abort("copernicusmarine is not installed or not in your PATH.")
  } else {
    cli::cli_inform("copernicusmarine is installed: {result}")
  }
}


build_cli <- function(dataset_id, date, bbox, out_dir) {
  variable <- variables[[dataset_id]]
  if (is.null(variable)) cli_abort("Unknown dataset {dataset_id}")

  variable_string <- glue_collapse(glue("--variable {variable}"), sep = " ")

  xmin <- bbox[1L, ]
  xmax <- bbox[2L, ]
  ymin <- bbox[3L, ]
  ymax <- bbox[4L, ]

  username <- Sys.getenv("COPERNICUS_USER")
  password <- Sys.getenv("COPERNICUS_PWD")

  command <- glue(
    "copernicusmarine subset ",
    "--dataset-id {dataset_id} ",
    "{variable_string} ",
    "-o {out_dir} ",
    "--service arco-geo-series ",
    "--dataset-part='default' ",
    "--force-download ",
    "--username {username} ",
    "--password '{password}' ",
    "--start-datetime {date} ",
    "--end-datetime {date} ",
    "--minimum-longitude {xmin} ",
    "--maximum-longitude {xmax} ",
    "--minimum-latitude {ymin} ",
    "--maximum-latitude {ymax} ",
    "--minimum-depth 0 ",
    "--maximum-depth 0 "
  )

  command
}

# Build the cli command for each image to download
download <- function(dataset_id, date, bbox, out_dir) {
  command <- build_cli(dataset_id, date, bbox, out_dir)
  system(command, intern = TRUE)
}

batch_download <- function(stations) {
  check_copernicusmarine()

  out_dir <- path("data", "raw", "copernicus")
  dir_delete(out_dir)
  dir_create(out_dir)


  stations_vec <- stations |>
    vect(geom = c("longitude", "latitude"), crs = "EPSG:4326")

  bbox <- stations_vec |>
    ext() |>
    extend(c(5L, 0L))

  dataset <- c(
    "cmems_mod_arc_phy_my_topaz4_P1D-m",
    "cmems_mod_arc_bgc_anfc_ecosmo_P1D-m",
    "cmems_mod_arc_phy_anfc_6km_detided_P1D-m"
  )

  res <- stations |>
    arrange(sampling_date) |>
    group_nest(sampling_date) |>
    crossing(dataset)

  future_pwalk(
    list(res[["dataset"]], res[["sampling_date"]], list(bbox), out_dir),
    download
  )

  res |>
    unnest(data)
}
