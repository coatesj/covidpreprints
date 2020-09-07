#' @import tidyverse
#' @import lubridate
#' @import googlesheets4
#' @import europepmc
#' @import rAltmetric
#' @import httr
#' @import jsonlite

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
