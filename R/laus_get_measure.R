# laus_get_measure.R
#
#' @title Acquire the measure code used in the series id for observations in Labor Area Unemployment Statistics (LAUS) data
#' @description Gathers the measure code used in the laus_get_data function to acquire a data frame using the blsAPI function that request data through the U.S. Bureau of Labor Statistics API. The laus_get_areacode function is called by the laus_get_data function not the user.
#' @param measure a string containing the desired measure. Exs: unemployment rate, labor force, employment, etc.
#' @details See <\url{https://download.bls.gov/pub/time.series/la/la.measure}> to see the format of the strings used in the measure param found in the measure_text column
#' @return returns a string representing a measure code
#' @export laus_get_measure
#' @
#' @examples
#' library(blsAPI)
#' laus_get_measure("unemployment rate")
laus_get_measure <- function(measure){
  #
  data("laus_measure", envir = environment())
  #
  laus_df <- subset(laus_measure, laus_measure$measure_text %in% measure, select = c("measure_code", 'measure_text'))
  #
  laus_vector <- laus_df$measure_code
  return(laus_vector)
}

