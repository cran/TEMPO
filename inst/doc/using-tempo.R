## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----list-tables, eval = FALSE------------------------------------------------
# library(TEMPO)
# 
# tables <- tempo_toc(language = "en")
# head(tables)

## ----search-tables, eval = FALSE----------------------------------------------
# population_tables <- tables[
#   grepl("population", tables$name, ignore.case = TRUE),
#   c("name", "code")
# ]
# head(population_tables)

## ----detailed-toc, eval = FALSE-----------------------------------------------
# table_details <- tempo_toc(full_description = TRUE, language = "en")
# head(table_details)

## ----download-one, eval = FALSE-----------------------------------------------
# data_directory <- file.path(tempdir(), "tempo-data")
# 
# files <- tempo_bulk(
#   codes = "ACC101B",
#   language = "en",
#   directory = data_directory
# )
# 
# files

## ----read-csv, eval = FALSE---------------------------------------------------
# csv_path <- file.path(data_directory, "ACC101B.csv")
# accidents <- utils::read.csv(
#   csv_path,
#   stringsAsFactors = FALSE,
#   check.names = FALSE
# )
# utils::head(accidents)

## ----download-many, eval = FALSE----------------------------------------------
# codes <- c("ACC101B", "ACC101C")
# files <- tempo_bulk(codes, language = "ro", directory = data_directory)

## ----incremental, eval = FALSE------------------------------------------------
# tempo_bulk("ACC101B", language = "en", directory = data_directory)
# #> Skipping `ACC101B`: the local CSV is up to date.

## ----error-handling, eval = FALSE---------------------------------------------
# tables <- tryCatch(
#   tempo_toc(language = "en"),
#   error = function(error) {
#     message("TEMPO Online is unavailable: ", conditionMessage(error))
#     NULL
#   }
# )

