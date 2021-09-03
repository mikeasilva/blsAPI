# laus_get_areacode
#
#' @title Acquire the area code used in the series id for observations in Labor Area Unemployment Statistics (LAUS) data
#' @description Gathers the area code used in the laus_get_data function to acquire a data frame using the blsAPI function that request data through the U.S. Bureau of Labor Statistics API. The laus_get_areacode function is called by the laus_get_data function not the user.
#' @param Location_Name a string or a list containing the state name, city and state name, or the metripolitian statistical area name and state
#' @details See <\url{https://download.bls.gov/pub/time.series/la/la.area}> to see the format of the strings used in the measure param found in the area_text column
#' @export laus_get_areacode
#' @return returns a string or list representing area codes
#' @examples
#' library(blsAPI)
#' laus_get_areacode(Location_Name = c("Florida", "California", 
#'                     "Charlotte County, FL", "Fresno County, CA"))
#' 
laus_get_areacode <- function(Location_Name){
  # Loading in the Area Code rda file
  data("LAUS_AreaCodes", envir = environment())
  #
  laus_df <- subset(LAUS_AreaCodes, LAUS_AreaCodes$area_text %in% Location_Name, select = c("area_code", 'area_text'))
  #
  laus_vector <- laus_df$area_code
  return(laus_vector)
}