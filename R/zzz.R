#' @importFrom googlesheets4 gs4_deauth
.onLoad <- function(libname, pkgname) {

  # Set Google de-authentication mode as sheet is public
  # N.B. Authentication will be required if sheet is made private
  gs4_deauth()

}
