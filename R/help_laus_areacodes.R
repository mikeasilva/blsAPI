# help_laus_areacodes

#' @title Prints a list of area names associated to an area code for the LAUS data
#' @return prints a list in the console
#' @export help_laus_areacodes
#'
#' @examples
#' library(blsAPI)
#' library(dplyr)
#' help_laus_areacodes() 
#' 
help_laus_areacodes <- function(){
  data("LAUS_AreaCodes", envir = environment())
  AreaName <- select(LAUS_AreaCodes, "area_text")
  print.data.frame(AreaName)
}
