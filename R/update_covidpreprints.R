#' @export
update_covidpreprints <- function(sheet_url) {

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
    arrange(date)

}
