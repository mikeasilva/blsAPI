## BLS API.R
#
#' This function allows users to request data from the BLS API.  
#' See http://www.bls.gov/developers/ and http://www.bls.gov/developers/api_signature.htm for more details.
#' @param data Information to send to the API.
#' @keywords bls api economics
#' @export
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
#' payload <- list('seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'), 'startyear'='2010', 'endyear'='2012')
#' response <- blsAPI(payload)
#' json <- fromJSON(response)

blsAPI <- function(data=NA){
  require(rjson)
  require(RCurl)
  h = basicTextGatherer()
  h$reset()
  if(is.na(data)){
    message('blsAPI: No parameters specified.')
  }
  else{
    ## Parameters specified so make the request
    if(is.list(data)){
      ## Multiple Series or One or More Series, Specifying Years request
      curlPerform(url='http://api.bls.gov/publicAPI/v1/timeseries/data/',
                httpheader=c('Content-Type' = "application/json;"),
                postfields=toJSON(data),
                verbose = FALSE, 
                writefunction = h$update
      )
    }else{
      ## Single Series request
      curlPerform(url=paste0('http://api.bls.gov/publicAPI/v1/timeseries/data/',data),
                verbose = FALSE, 
                writefunction = h$update
      )
    }
  }
  h$value()
}