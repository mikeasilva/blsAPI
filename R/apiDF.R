# apiDF.R
#
#' @title Creates data frame after data is called using blsAPI.R
#' @description Used in the laus_get_data function
#' @param data The JSON used to extract the data gathered from the blsAPI function
#' @return returns a data frame of the data requested from the bLSAPI function call
#' @export apiDF
#' @import rjson
#' @examples
#' library(blsAPI)
#' library(rjson)
#' response <- blsAPI('LAUCN040010000000005')
#' json <- fromJSON(response)
#' df <- apiDF(json$Results$series[[1]]$data)
#' 
apiDF <- function(data){
  df <- data.frame(year=character(),
                   period=character(),
                   periodName=character(),
                   value=character(),
                   stringsAsFactors=FALSE)
  
  i <- 0
  for(d in data){
    i <- i + 1
    df[i,] <- c(d$year, d$period, d$periodName, d$value)
  }
  return(df)
}