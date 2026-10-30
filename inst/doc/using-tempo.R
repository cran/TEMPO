## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(TEMPO)

## ----tour, eval = FALSE-------------------------------------------------------
#  library(TEMPO)
#  
#  # 1. Find a table.
#  tables <- tempo_search("unemployed", language = "en")
#  tables[, c("code", "name")]
#  
#  # 2. Look at its structure, and its size, before downloading anything.
#  meta <- tempo_meta("SOM101E", language = "en")
#  meta
#  
#  # 3. Pull the slice you need straight into a data frame.
#  unemployment <- tempo_get(
#    "SOM101E",
#    filters = list(
#      Sex        = "Total",
#      Counties   = "Cluj",
#      Localities = "TOTAL",
#      Periods    = grep("2024", meta$values$Periods$label, value = TRUE)
#    ),
#    language = "en"
#  )
#  head(unemployment)

## ----list-tables, eval = FALSE------------------------------------------------
#  tables <- tempo_toc(language = "en")
#  nrow(tables)
#  head(tables)

## ----search, eval = FALSE-----------------------------------------------------
#  tempo_search(c("population", "migration"), language = "en")
#  
#  # Reuse a table of contents you already hold rather than fetching it again.
#  tempo_search("population", toc = tables)

## ----hierarchy, eval = FALSE--------------------------------------------------
#  branches <- tempo_hierarchy(language = "en", matrices = FALSE)
#  table(branches$level)
#  subset(branches, level == 1, select = c(code, name))

## ----hierarchy-matrices, eval = FALSE-----------------------------------------
#  tree <- tempo_hierarchy(language = "en")
#  
#  # Where does one matrix sit?
#  tree[tree$code == "POP105A", c("level", "path")]
#  
#  # Every matrix under one domain.
#  population <- tree[tree$is_matrix & grepl("POPULATIE", tree$path), ]
#  head(population[, c("code", "name")])

## ----detailed-toc, eval = FALSE-----------------------------------------------
#  described <- tempo_toc(full_description = TRUE, language = "en")
#  head(described[, c("code", "Statistical_domain", "Last_update")])
#  
#  # What has been revised most recently?
#  head(described[order(described$Last_update, decreasing = TRUE), ])

## ----meta, eval = FALSE-------------------------------------------------------
#  meta <- tempo_meta("SOM101E", language = "en")
#  meta
#  #> <tempo_meta> SOM101E
#  #>   A. SOCIAL STATISTICS > LABOUR FORCE > REGISTERED UNEMPLOYED
#  #>   language:    en
#  #>   last update: 2026-10-12
#  #>   full table:  88,663,248 cells, over 2,000 requests
#  #>                too large to fetch whole; select values with tempo_get()
#  #>   dimensions:  5
#  #>     1. Sex (3 values): Total, Male, Female
#  #>     2. Counties (43 values): TOTAL, Alba, Arad, ...
#  #>     3. Localities (3182 values): TOTAL, 1017 ALBA IULIA MUNICIPALITY, ...
#  #>     4. Periods (216 values): Year 2010, January 2010, February 2010, ...
#  #>     5. MU: Persons (1 value): Number of persons

## ----meta-parts, eval = FALSE-------------------------------------------------
#  meta$dimensions      # one row per dimension, with how many values each has
#  meta$cells           # size of a full download
#  meta$requests        # how many HTTP requests that would take
#  meta$values$Years    # the selectable values, with the service's identifiers

## ----get, eval = FALSE--------------------------------------------------------
#  unemployment <- tempo_get(
#    "SOM101E",
#    filters = list(
#      Sex        = "Total",
#      Counties   = "Cluj",
#      Localities = "TOTAL",
#      Periods    = grep("2024", meta$values$Periods$label, value = TRUE)
#    ),
#    language = "en"
#  )

## ----get-error, eval = FALSE--------------------------------------------------
#  tempo_get("SOM101E", filters = list(Counties = "Atlantis"), language = "en")
#  #> Error: No value of dimension "Counties" matches "Atlantis". Available
#  #> values (first 10 of 43): TOTAL; Alba; Arad; Arges; Bacau; ...

## ----get-naming, eval = FALSE-------------------------------------------------
#  tempo_get("SOM101E", filters = list(Count = "Cluj", Period = "January 2024"),
#            language = "en")

## ----tidy-input---------------------------------------------------------------
csv <- paste(
  "Judete,Ani,UM: Numar persoane,Valoare",
  "Cluj,Anul 2019,Numar persoane,1234",
  "Cluj,Anul 2020,Numar persoane,:",
  "Bihor,Anul 2019,Numar persoane,987",
  ",,,(c) INS 1998-2026",
  sep = "\n"
)
cat(csv)

## ----tidy-output--------------------------------------------------------------
tidy <- tempo_tidy(csv, code = "DEMO101A")
tidy
str(tidy)

## ----tidy-monthly-------------------------------------------------------------
monthly <- paste(
  "Luni,Ani,UM: Numar,Valoare",
  "luna ianuarie,Anul 2024,Numar,10",
  "luna februarie,Anul 2024,Numar,12",
  "luna decembrie,Anul 2024,Numar,14",
  sep = "\n"
)
tempo_tidy(monthly)

## ----tidy-mixed---------------------------------------------------------------
mixed <- paste(
  "Counties,Periods,UM: Persons,Value",
  "Cluj,Year 2010,Number of persons,100",
  "Cluj,January 2010,Number of persons,8",
  "Cluj,February 2010,Number of persons,9",
  sep = "\n"
)
tempo_tidy(mixed)

## ----tidy-odd-----------------------------------------------------------------
odd <- paste(
  "Judete,Ani,UM: Numar,Valoare",
  "Cluj,Anul 2019,Numar,1234",
  "Bihor,Anul 2019,Numar,confidential",
  sep = "\n"
)
suppressWarnings(tempo_tidy(odd))

## ----bulk, eval = FALSE-------------------------------------------------------
#  data_directory <- file.path(tempdir(), "tempo-data")
#  
#  files <- tempo_bulk(
#    codes = c("ACC101B", "ACC101C"),
#    language = "en",
#    directory = data_directory
#  )
#  
#  files
#  attr(files, "downloaded")
#  attr(files, "reason")

## ----bulk-read, eval = FALSE--------------------------------------------------
#  accidents <- tempo_tidy(files[["ACC101B"]], code = "ACC101B")

## ----bulk-incremental, eval = FALSE-------------------------------------------
#  tempo_bulk("ACC101B", language = "en", directory = data_directory)
#  #> Skipping `ACC101B`: the local CSV is up to date.
#  #> All requested CSV files are up to date.
#  
#  # Asking for the other language re-downloads rather than reusing the file.
#  tempo_bulk("ACC101B", language = "ro", directory = data_directory)
#  
#  # Force a download regardless.
#  tempo_bulk("ACC101B", language = "en", directory = data_directory,
#             overwrite = TRUE)

## ----options, eval = FALSE----------------------------------------------------
#  options(
#    TEMPO.max_cells = 1e5,       # larger single queries
#    TEMPO.max_connections = 2,   # gentler on the service
#    TEMPO.throttle = 0.2         # at least 0.2s between requests
#  )

## ----cache--------------------------------------------------------------------
tempo_cache_dir()

## ----cache-persistent, eval = FALSE-------------------------------------------
#  tempo_cache_dir(tools::R_user_dir("TEMPO", "cache"))
#  
#  # Or, in a project .Rprofile:
#  options(TEMPO.cache_dir = tools::R_user_dir("TEMPO", "cache"))
#  
#  tempo_cache_clear()

## ----conditions---------------------------------------------------------------
tryCatch(
  tempo_toc(language = "fr"),
  tempo_input_error = function(condition) "my call was wrong",
  tempo_offline_error = function(condition) "the service is unreachable",
  tempo_error = function(condition) "something else"
)

## ----conditions-live, eval = FALSE--------------------------------------------
#  # Read the HTTP status, and retry only what is worth retrying.
#  tryCatch(
#    tempo_get("ACC101B"),
#    tempo_http_error = function(condition) {
#      message("HTTP ", condition$status_code, " from ", condition$url)
#      NULL
#    },
#    tempo_offline_error = function(condition) {
#      Sys.sleep(60)
#      tempo_get("ACC101B")
#    }
#  )

