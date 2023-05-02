# blsAPI — U.S. Bureau of Labor Statistics Data for R  


blsAPI is an R package that allows users to request data for one or multiple series through the U.S. Bureau of Labor Statistics (BLS) Application Programming Interface (API).  The BLS API gives the public access to economic data from all BLS programs. 

## Quick Tour 

### Installation  
blsAPI can be installed easily through [CRAN](https://cran.r-project.org/package=blsAPI) or [GitHub](https://github.com/mikeasilva/blsAPI).    

#### CRAN  

```r
install.packages('blsAPI')
```

#### GitHub  

```r
library(devtools)
install_github('mikeasilva/blsAPI')
```

### API Basics  
The blsAPI package supports two versions of the BLS API.  API Version 2.0 requires registration and offers greater query limits. It also allows users to request net and percent changes and series description information. See below for more details.

| Service                                  |  Version 2.0 (Registered)  |  Version 1.0 (Unregistered)  |
|:-----------------------------------------|:--------------------------:|:----------------------------:|
| Daily query limit                        |            500             |              25              |
| Series per query limit                   |             50             |              25              |
| Years per query limit                    |             20             |              10              |
| Net/Percent Changes                      |            Yes             |              No              |
| Optional annual averages                 |            Yes             |              No              |
| Series description information (catalog) |            Yes             |              No              |

### Sample Code

#### Example 1
The following example will retrieve the civilian unadjusted Employment Cost Index (ECI) via the API and process the request into a data frame.


```r
library(rjson)
library(blsAPI)

response <- blsAPI('CIU1010000000000A')
json     <- fromJSON(response)

data_list  <- json$Results$series[[1]]$data[-1]
cpi        <- data.frame(matrix(unlist(data_list), ncol = 4, byrow = TRUE, 
                          dimnames = list(NULL, c("year", "period", 
                                                  "periodName", "value"))), 
                                                   stringsAsFactors = FALSE)
cpi

```

The resulting data frame looks like this (Note: Your results may look different depending on when you pull the data):  


|  year  |  period  |  periodName  |  value  |
|:------:|:--------:|:------------:|:-------:|
|  2014  |   Q03    | 3rd Quarter  |   2.2   |
|  2014  |   Q02    | 2nd Quarter  |   2.0   |
|  2014  |   Q01    | 1st Quarter  |   1.8   |
|  2013  |   Q04    | 4th Quarter  |   2.0   |
|  2013  |   Q03    | 3rd Quarter  |   1.9   |
|  2013  |   Q02    | 2nd Quarter  |   1.9   |
|  2013  |   Q01    | 1st Quarter  |   1.9   |
|  2012  |   Q04    | 4th Quarter  |   1.9   |
|  2012  |   Q03    | 3rd Quarter  |   1.9   |
|  2012  |   Q02    | 2nd Quarter  |   1.7   |
|  2012  |   Q01    | 1st Quarter  |   1.9   |

#### Example 2
This example pulls monthly unemployment and labor force estimates for Manhattan (New York County, NY) using the version 2.0 API.  We graph a calculated unemployment rate including shading for the Great Recession.  According the [National Bureau of Economic Research (NBER)](http://www.nber.org/cycles.html) the Great Recession ran from December 2007 to June 2009.


```r
library(rjson)
library(blsAPI)
library(ggplot2)

## Pull the data via the API
payload <- list(
  'seriesid'=c('LAUCN360610000000004', 'LAUCN360610000000006'),
  'startyear'=2007,
  'endyear'=2009)
response <- blsAPI(payload, 2)
json     <- fromJSON(response)

## Process results
apiDF <- function(data) {
  df  <- data.frame(matrix(unlist(data), nrow = length(data), byrow = TRUE))
  colnames(df) <- c("year", "period", "periodName", "value")
  return(df)
}


unemployed.df  <- apiDF(json$Results$series[[1]]$data)
labor.force.df <- apiDF(json$Results$series[[2]]$data)

## Change value type from character to numeric
unemployed.df[,4]  <- as.numeric(unemployed.df[,4])
labor.force.df[,4] <- as.numeric(labor.force.df[,4])

## Rename value prior to merging
names(unemployed.df)[4]  <- 'unemployed'
names(labor.force.df)[4] <- 'labor.force'

## Merge data frames
df <- merge(unemployed.df, labor.force.df)

## Create date and unemployement rate
df$unemployment.rate <- df$unemployed / df$labor.force
df$date <- as.POSIXct(strptime(paste0('1',df$periodName,df$year), '%d%B%Y'))

## Beginning and end dates for the Great Recession (used in shaded area)
gr.start <- as.POSIXct(strptime('1December2007', '%d%B%Y'))
gr.end   <- as.POSIXct(strptime('1June2009', '%d%B%Y'))

## Plot the data
ggplot(df) + geom_rect(aes(xmin = gr.start, xmax = gr.end, ymin = -Inf, ymax = Inf), alpha = 0.4, fill="#DDDDDD") + geom_line(aes(date, unemployment.rate*100)) + ylab('Percent of labor force')  + xlab('Great Recession shaded in gray') + ggtitle('Unemployment Rate for Manhattan, NY (Jan 2007 to Dec 2010)') + theme_bw()
```

![](https://github.com/mikeasilva/blsAPI/blob/master/figure/unnamed-chunk-8-1.png) 

## Quarterly Census of Employment and Wages (QCEW) Open Data
The BLS has made QCEW data available through an open data access option.  This package can access this data.

```r
## Request the first quarter of 2017 for the state of Michigan
MichiganData <- blsQCEW('Area', year='2017', quarter='1', area='26000')
```

Please see the help file for more options and example code.

## Labor Area Unemployment Statistics Function
The laus_get_data() function is a wrapper of the blsAPI() function that makes it easier to get the labor area unemployment data without knowing the Series ID for the specific area and measure you want. A few examples of a measure would be the unemployment rate, or the labor force. 

#### Example
This example pulls the unemployment rate for California, Florida, Texas, and Nevada from 2019 to 2021.

```r
library(rjson)
library(blsAPI)
library(dplyr)

unemployment_rate <- laus_get_data(c("California", "Florida", "Texas", "Nevada"), "unemployment rate", 2019, 2021)
```

The resulting data frame will look like this for the first four rows
|  year  |  period  |  periodName  |  Unemployment_Rate  | Location   |
|:------:|:--------:|:------------:|:-------------------:|:----------:|
|  2021  |   M07    | July         |   2.2               | California |
|  2021  |   M06    | June         |   2.0               | California |
|  2021  |   M05    | May          |   1.8               | California |
|  2021  |   M04    | April        |   2.0               | California |

For more examples of this function and to learn more about it type ?laus_get_data in your R console. 

## Learning More
With the basics described above you can get started with the BLS API right away. To learn more see:  

* [BLS API Home](http://www.bls.gov/developers/)
* [BLS API FAQ](http://www.bls.gov/developers/api_faqs.htm) 
* [BLS Help & Tutorials: Series ID Formats](http://www.bls.gov/help/hlpforma.htm)  
* [Register for BLS API v 2.0](http://data.bls.gov/registrationEngine/)  
