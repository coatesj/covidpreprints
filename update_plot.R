library(httr)

list_preprints_url <- "https://api.biorxiv.org/covid19/"

latest_preprints <- content(GET(paste0(list_preprints_url, 0)))

total_nb <- latest_preprints$messages[[1]]$total

res <- latest_preprints$collection

for (i in seq(30, total_nb, by = 30)) {

  preprints <- content(GET(paste0(list_preprints_url, i)))

  res <- c(res, preprints$collection)

}

df <- lapply(res, function(e) c(e$rel_date, e$rel_site))
df <- do.call(rbind.data.frame, df)
colnames(df) <- c("date", "site")

library(dplyr)
df <- df %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= "2020-01-01") %>%
  count(date, site) %>%
  mutate(tot = cumsum(n))

saveRDS(df, "preprints_covid.rds")
