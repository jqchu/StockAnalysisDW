
totime <- function(x,...){
  str <- unlist(strsplit(x,...))
  data.frame(year =str[1],month = str[2],day = str[3])
}
totimes <- function(stock){
  ldply(as.character(stock$date),totime,"-")
}

#####函数工厂，在生成月操作函数是只需要制定操作函数和标签即可，不需要重复编写按月分隔函数
#'@return  生成的月操作函数
toMonthOpt <- function(f,tab){
  
  force(f)
  force(tab)
  function(stock){
    if(("month" %in% names(stock))){
      timeT <-  stock
    }else{
      timeT <- totimes(stock)
      timeT  <- cbind(timeT,stock)
    }
    ddply(timeT,.variables = .(year,month),function(x,tab){
      date <- paste(x$year[1],x$month[1],sep="-")
      temp <- f(x)
      res <- data.frame(date =date,temp =temp)
      names(res) <- c("date",tab)
      res
    },tab)
  }
} 

###所有的生成函数
monthOpen <- toMonthOpt(function(x) x$open[1],"open")
monthHigh <- toMonthOpt(function(x) max(x$high),"high")
monthLow <- toMonthOpt(function(x) min(x$low),"low")
monthVolume <- toMonthOpt(function(x) sum(x$volume),"volume")
monthClose <- toMonthOpt(function(x) x$close[nrow(x)],"close")     
monthTotalPay <- toMonthOpt(function(x) sum(x$total_pay),"total_pay")     

#####an example

pufa <- read.csv("lipufa.csv") ###读取你自己下载回来的数据
monthOpen(pufa)




