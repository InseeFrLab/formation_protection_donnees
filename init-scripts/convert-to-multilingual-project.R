library(babelquarto)
library(babeldown)

source("init-scripts/api-keys.R")
# Sys.setenv("DEEPL_API_URL" = "https://api.deepl.com") # Ignore if free deepl api account
keyring::key_set("deepl", prompt = "API key:")
Sys.setenv(DEEPL_API_KEY = keyring::key_get("deepl"))

babelquarto::register_main_language(main_language = "fr")
babelquarto::register_further_languages(further_languages = "en")

# Useful only for translating small qmd files using deepl
gen_english_qmds <- function(dir) {
  qmds_fr <- list.files(
    dir,
    pattern = ".qmd",
    full.names = TRUE,
    recursive = FALSE
  )

  qmds_fr <- qmds_fr[!grepl("\\.en\\.qmd$", qmds_fr)]

  res <- purrr::walk(
    qmds_fr,
    \(f) {
      tryCatch(
        {
          p <- babeldown::deepl_translate(
            path = f,
            out_path = sub(".qmd$", ".en.qmd", f),
            source_lang = "FR",
            target_lang = "EN-US"
          )
          return(TRUE)
        },
        error = function(e) {
          return(FALSE)
        }
      )
    }
  )
  names(res) <- qmds_fr
  return(res)
}

# gen_english_qmds(".")
# gen_english_qmds("./theorie")
# gen_english_qmds("./pratique")
# gen_english_qmds("./theorie/supports")
# gen_english_qmds("./pratique/fiches")
