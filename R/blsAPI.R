## blsAPI.R
#
#' @title Request data from the Bureau of Labor Statistics' API
#' @description Allows users to request data for one or multiple series through the BLS API.  Users provide parameters as specified in \url{http://www.bls.gov/developers/api_signature.htm} and the function returns a JSON string.
#' @details See \url{http://www.bls.gov/developers/} and \url{http://www.bls.gov/developers/api_signature.htm} for more details.
#' @param payload data sent to the API.
#' @keywords bls api economics
#' @examples
#' ## These examples are taken from http://www.bls.gov/developers/api_signature.htm
#' 
#' ## Single Series request
#' response <- blsAPI('LAUCN040010000000005')
#' json <- fromJSON(response)
#' 
#' ## Multiple Series 
#' payload <- list('seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'))
#' response <- blsAPI(payload)
#' json <- fromJSON(response)
#' 
#' ## One or More Series, Specifying Years
#' payload <- list(
#'  'seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'), 
#'  'startyear'=2010, 
#'  'endyear'=2012)
#' response <- blsAPI(payload)
#' json <- fromJSON(response)

blsAPI <- function(payload=NA){
  #library(rjson)
  #library(RCurl)
  h = basicTextGatherer()
  h$reset()
  if(class(payload)=='logical'){
    message('blsAPI: No parameters specified.')
  }
  else{
    ## Parameters specified so make the request
    if(is.list(payload)){
      ## Multiple Series or One or More Series, Specifying Years request
      curlPerform(url='http://api.bls.gov/publicAPI/v1/timeseries/data/',
                httpheader=c('Content-Type' = "application/json;"),
                postfields=toJSON(payload),
                verbose = FALSE, 
                writefunction = h$update
      )
    }else{
      ## Single Series request
      curlPerform(url=paste0('http://api.bls.gov/publicAPI/v1/timeseries/data/',payload),
                verbose = FALSE, 
                writefunction = h$update
      )
    }
  h$value()  
  }
}