#' @import tidyverse
#' @import lubridate
#' @import googlesheets4
#' @import europepmc
#' @import rAltmetric
#' @import httr
#' @import jsonlite

# Set Google Sheet URL
sheet_url <- "https://docs.google.com/spreadsheets/d/1BES52D4nYUZjV6kx1S_lJKSHvC9I0uzPTFA2mcxv4FI"

# Function to get various info from Europe PMC
epmc <- function(doi){
  data <- epmc_search_by_doi(doi = doi,
                             output = "raw")[[1]][[1]]
  if(length(data[["commentCorrectionList"]]) > 0){
    l <- data[["commentCorrectionList"]][["commentCorrection"]]
    for(i in l){
      if(i[["type"]] == "Preprint of"){
        pub_doi <- epmc_details(i[["id"]], i[["source"]])[["basic"]][["doi"]]
    }
    }
  } else {
    pub_doi <- NA
  }
  prelights_link <- epmc_lablinks(ext_id = data$id, data_src = data$source,
                                  lab_id = "1859", verbose = FALSE) %>%
    { map_chr(.$link, "url") }
  if(is_empty(prelights_link)) prelights_link <- NA
  return(tibble(title = data[["title"]],
                date = as_date(data[["firstPublicationDate"]]),
                authorString = str_c(str_split(data[["authorString"]],
                                               ", ")[[1]][[1]], " et al."),
                publishedVersionDoi = pub_doi,
                citationCount = data[["citedByCount"]],
                preLightsUrl = prelights_link))
}

# Function to return Altmetric info for a DOI
altmetric <- function(doi){
  data <- altmetrics(doi = doi) %>%
    altmetric_data()
  return(tibble(altmetricScore = ceiling(as.integer(data$score)),
                tweeters = data$cited_by_tweeters_count,
                altmetricDonut = data$images.small,
                altmetricUrl = data$details_url))
}

# Read Google Sheet (Preprints tab) and add data
preprints <- read_sheet(sheet_url, sheet = "Preprints") %>%
  filter(class %in% c("preprint", "bad")) %>% # filter non-preprints
  filter(!str_detect(id, "arXiv")) %>% # filter arXiv preprints (for now...)
  mutate(publication = map(id, epmc),
         altmetric = map(id, altmetric),
         url = str_c("https://doi.org/", id)) %>%
  unnest(publication, altmetric)

# Read Google Sheet (Events tab)
events <- read_sheet(sheet_url, sheet = "Events") %>%
  filter(class %in% c("event"))

# Combine and write to JSON object
combined <- bind_rows(preprints, events) %>%
  select(date, class, title, url,
         briefSummary, longerSummary,
         authorString, publishedVersionDoi, citationCount,
         altmetricScore, altmetricUrl, altmetricDonut, tweeters,
         preLightsUrl
         ) %>%
  arrange(date) %>%
  write_json(., "data.json", pretty = TRUE)

# Set GitHub URL and folder name for the Sinai reviews
github_url <- "https://api.github.com/repos/ismms-himc/covid-19_sinai_reviews/git/trees/master"
folder_name <- "markdown_files"

# Find URL for the folder
for(i in content(GET(github_url))$tree){
  if(i$path == folder_name){
    folder_url <- i$url
  }
}

# Write all .md files to "sinai" folder
for(i in content(GET(folder_url))$tree){
  name = i$path
  if(str_detect(name, r"(\.md$)")){
      file_url <- str_c("https://raw.githubusercontent.com/ismms-himc/covid-19_sinai_reviews/master/",
                        folder_name, "/", name)
      write(content(GET(file_url)), file = str_c("./sinai/", name))
  }
}
