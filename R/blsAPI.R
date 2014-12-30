## blsAPI.R
#
#' @title Request Data From The U.S. Bureau Of Labor Statistics' API
#' @description Allows users to request data for one or multiple series through the U.S. Bureau of Labor Statistics' API.  Users provide parameters as specified in \url{http://www.bls.gov/developers/api_signature.htm} and the function returns a JSON string.
#' @details See \url{http://www.bls.gov/developers/} and \url{http://www.bls.gov/developers/api_signature.htm} for more details on the payload.
#' @param payload a string or a list containing data to be sent to the API.
#' @param api.version an integer for which api version you want to use (i.e. 1 for v1, 2 for v2)
#' @keywords bls api economics
#' @export blsAPI
#' @import rjson RCurl
#' @examples
#' ## These examples are taken from http://www.bls.gov/developers/api_signature.htm
#' library(rjson)
#' library(blsAPI)
#' 
#' ## API Version 1.0 R Script Sample Code
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
#'   'seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'),
#'   'startyear'=2010,
#'   'endyear'=2012)
#' response <- blsAPI(payload)
#' json <- fromJSON(response)
#' 
#' ## API Version 2.0 R Script Sample Code
#' ## Single Series
#' response <- blsAPI('LAUCN040010000000005', 2)
#' json <- fromJSON(response)
#' 
#' ## Multiple Series
#' payload <- list('seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'))
#' response <- blsAPI(payload, 2)
#' json <- fromJSON(response)
#' 
#' ## One or More Series with Optional Parameters
#' payload <- list(
#'   'seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'),
#'   'startyear'=2010,
#'   'endyear'=2012,
#'   'catalog'=FALSE,
#'   'calculations'=TRUE,
#'   'annualaverage'=TRUE,
#'   'registrationKey'='995f4e779f204473aa565256e8afe73e')
#' response <- blsAPI(payload, 2)
#' json <- fromJSON(response)

blsAPI <- function(payload=NA, api.version=1){
  h = basicTextGatherer()
  h$reset()
  if(class(payload)=='logical'){
    ## Payload not defined
    message('blsAPI: No payload specified.')
  }
  else{
    ## Payload specified so make the request
    api.url <- paste0('http://api.bls.gov/publicAPI/v',api.version,'/timeseries/data/')
    if(is.list(payload)){
      ## Multiple Series or One or More Series, Specifying Years request
      curlPerform(url=api.url,
                httpheader=c('Content-Type' = "application/json;"),
                postfields=toJSON(payload),
                verbose = FALSE, 
                writefunction = h$update
      )
    }else{
      ## Single Series request
      curlPerform(url=paste0(api.url,payload),
                verbose = FALSE, 
                writefunction = h$update
      )
    }
  h$value()  
  }
}