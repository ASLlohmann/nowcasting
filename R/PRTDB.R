#' @title Pseudo Real Time Data Base
#' @description Create a pseudo real time data base based on data and delays of disclosure stipulated by the user.
#' @param mts A \code{mts} with the series data.
#' @param delay A numeric vector with the delay in days the information is available after the reference month. Each element corresponds to the series in the respective column in \code{mts}. 
#' @param vintage The day when the data is supposed to be collected.
#' @return A \code{mts} with the series transformed.
#' @examples 
#' # Pseudo Real Time Data Base from data base BRGDP
#' PRTDB(mts = BRGDP$base, delay = BRGDP$delay, vintage = "2017-10-01")
#' @import zoo lubridate
#' @importFrom stats is.mts
#' @export

PRTDB<-function(mts, delay, vintage = Sys.Date()){
  
  if(!(is.mts(mts) || is.ts(mts))){stop("The input should be a ts or mts object")}
  
  mts_new <- mts
  
  # define the last day of the month
  month_end <- as.Date(mts)+months(1)-days(1)
  
  # create a list with the release date of each variable
  release <- lapply(1:length(delay),function(x) month_end+days(delay)[x])
  
  # Eliminate information not available at the specified vintage day
  if(is.mts(mts)){
    for (i in 1:length(delay)){mts_new[release[[i]] > vintage, i] <- NA}
    mts_new <- ts(mts_new[!as.Date(mts_new) > vintage, ], start = start(mts_new), 
                  frequency = frequency(mts_new))
  }else{
    mts_new[release[[1]] > vintage] <- NA
    mts_new <- ts(mts_new[!as.Date(mts_new) > vintage], start = start(mts_new), 
                  frequency = frequency(mts_new))
  }
  
  return(mts_new)
}