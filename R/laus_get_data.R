# laus_get_data.R
#
#' @title A wrapper function for blsAPI.R function that processes gathered Labor Are Unemployment Statistics (LAUS) data into a data frame
#' @description Allows users to request LAUS data and have it downloaded as a data frame with ease
#' @param location.vector A string or list of the different cities, states or metropolitan statistical areas you want LAUS data from
#' @param measure.vector  A string of the laus measure you want to gather in your call, e.g. unemployment, unemployment rate.
#' @param start.year The year you want as the beginning period of data collection
#' @param end.year The year you want as the ending period of data collection
#' @param api.version A numerical value that specifies which version of the api you're using (1 or 2)
#' @param bls.key The BLS key you're using to retrive data using version 2
#' @export laus_get_data
#' @import dplyr rjson 
#' @examples
#' library(blsAPI)
#' library(dplyr)
#' library(rjson)
#' unem_df <- laus_get_data(location.vector = c("Florida", "California", 
#'                     "Charlotte County, FL", "Fresno County, CA"), 
#'                      measure.vector = "unemployment rate", 
#'                      start.year = 2019, end.year = 2021, 
#'                      api.version = 1)
#' 
laus_get_data <- function(location.vector, measure.vector, start.year, end.year, api.version=1, bls.key=NULL){
  
  # Saves the Fips codes to a vector for later use
  SeriesID <- laus_get_areacode(location.vector)
  
  # Saves the measure code to a vector for later use
  Measure_Code <- laus_get_measure(measure = measure.vector)
  
  # Initializes a blank character vector that has the series id for the LAUS data for each location
  location_vec <- character()
  
  for (i in SeriesID){
    location_vec <- c(location_vec, paste("LAU",i, Measure_Code, sep=""))
  }
  
  if (api.version==1){
  payload <- list(
    'seriesid'=c(location_vec),
    'startyear'=start.year,
    'endyear'=end.year)
  response <- blsAPI(payload, api_version = api.version)
  json <- fromJSON(response)
  return
  }else if(api.version==2){
    payload <- list(
      'seriesid'=c(location_vec),
      'startyear'=start.year,
      'endyear'=end.year,
      'registrationKey'=bls.key)
    response <- blsAPI(payload, api_version = api.version)
    json <- fromJSON(response)
  }
  
  df = data.frame(
    year = character(),
    period = character(),
    periodName = character(),
    value = numeric(),
    Location = character()
  )
  
  
  n = 1
  for (i in location.vector){
    temp <- apiDF(json$Results$series[[n]]$data)
    temp$Location <- i
    temp$value <- as.numeric(temp$value)
    df <- rbind(df, temp)
    n = n +1
  }
  
  # If Else Statements to Rename the Value Column
  if(Measure_Code == "03"){
    df <- dplyr::rename(df, Unemployment_Rate = value)
  }else if(Measure_Code == "04"){
    df <- dplyr::rename(df, Unemployment = value)
  }else if(Measure_Code == "05"){
    df <- dplyr::rename(df, Employment = value)
  }else if(Measure_Code == "06"){
    df <- dplyr::rename(df, Labor_Force = value)
  }else if(Measure_Code == "07"){
    df <- dplyr::rename(df, Employment_Pop_Ratio = value)
  }else if(Measure_Code == "08"){
    df <- dplyr::rename(df, Labor_Force_Participation_Rate = value)
  }else if(Measure_Code == "09"){
    df <- dplyr::rename(df, Civilian = value)
  }
  
  return(df)
}