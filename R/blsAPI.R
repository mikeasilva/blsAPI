## blsAPI.R
#
#' @title Request Data from the U.S. Bureau Of Labor Statistics API
#' @description Allows users to request data for one or multiple series through the U.S. Bureau of Labor Statistics API.  Users provide parameters as specified in \url{http://www.bls.gov/developers/api_signature.htm} and the function returns a JSON string or data frame.
#' @details See \url{http://www.bls.gov/developers/} and \url{http://www.bls.gov/developers/api_signature.htm} for more details on the payload.
#' @param payload a string or a list containing data to be sent to the API.
#' @param api.version an integer for which api version you want to use (i.e. 1 for v1, 2 for v2)
#' @param return.data.frame a boolean if you want to the function to return JSON (default) or a data frame. If the data frame option is used, the series id will be added as a column.  This is helpful if multiple series are selected.
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
#' \dontrun{
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
#' ## Or request a data frame
#' df <- blsAPI('LAUCN040010000000005', 2, TRUE)
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
#' }

blsAPI <- function(payload=NA, api.version=1, return.data.frame=FALSE){
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
      payload <- toJSON(payload)
      m <- regexpr('\\"seriesid\\":\\"[a-zA-Z0-9]*\\",', payload)
      str <- regmatches(payload, m)
      if(length(str)>0){
        ## wrap single series in []
        replace <- sub(',', '],', sub(':', ':[',str))
        payload <- sub(str, replace, payload)
      }
      curlPerform(url=api.url, httpheader=c('Content-Type' = "application/json;"), postfields=payload, verbose = FALSE, writefunction = h$update)
    }
    else{
      ## Single Series request
      curlPerform(url=paste0(api.url,payload), verbose = FALSE, writefunction = h$update)
    }
    ## Return the results of the API call
    if(return.data.frame){
      json <-fromJSON(h$value())
      ## Iterate over the series
      number.of.series = length(json$Results$series)
      for(i in 1:number.of.series){
        ## Set the default structure of the data frame
        df.start <- data.frame(year=character(), period=character(), periodName=character(), value=character(), stringsAsFactors=FALSE)
        j <- 0
        for(d in json$Results$series[[1]]$data){
          j <- j + 1
          ## Remove the footnotes from the list to stop the warnings
          d$footnotes <- NULL
          ## Add record to the data frame
          df.start[j,] <- unlist(d)
        }
        ## Add in the series id
        df.start$seriesID = json$Results$series[[i]]$seriesID
        ## Create the data frame that will be returned
        if(!exists("df.to.return")){
          ## Data frame to return not defined so create it
          df.to.return = df.start
        } 
        else {
          ## Append to the existing data frame
          df.to.return <- rbind(df.to.return, df.start)
        }
      }
      return(df.to.return)
    }
    else {
      ## Return the JSON results
      return(h$value()) 
    }
  }
}