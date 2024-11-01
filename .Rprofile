source("renv/activate.R")
options(
  repos = c(
    RSPM = "https://packagemanager.posit.co/cran/__linux__/noble/latest",
    CRAN = "https://cran.rstudio.com/"
  ),
  pillar.sigfig = 5L,
  pillar.bold = TRUE,
  pillar.max_footer_lines = Inf,
  HTTPUserAgent = sprintf(
    "R/%s R (%s)",
    getRversion(),
    paste(
      getRversion(),
      R.version[["platform"]],
      R.version[["arch"]],
      R.version[["os"]]
    )
  ),
  lintr.object_usage_linter = NULL,
  lintr.linter_file = "~/.lintr",
  # Disable completion from the language server
  languageserver.server_capabilities =
    list(
      completionProvider = FALSE,
      completionItemResolve = FALSE
    ),
  languageserver.formatting_style = function(options) {
    styler::tidyverse_style(
      scope = "indention",
      indent_by = options[["tabSize"]]
    )
  },
  languageserver.rich_documentation = FALSE,
  browser = "/usr/bin/firefox"
)

# Set default theme and color theme for ggplot2
setHook(packageEvent("ggplot2", "attach"), function(...) {
  ggplot2::theme_set(ggplot2::theme_bw())
  options(ggplot2.continuous.colour = "viridis")
  options(ggplot2.continuous.fill = "viridis")
})
