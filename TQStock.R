require(RCurl)
require(XML)
require(plyr)
require(TSA)
require(ggplot2)
require(foreach)

verifyYears  <- function(code,year.start,year.end,myheader){
  url  <-paste("http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/",
               code,".phtml?year=2014&jidu=1",sep="")
  webpage <- getURL(url,httpheader = myheader, curl = handle);
  
  pagetree <- htmlTreeParse(webpage,encoding="utf-8", error=function(...){}, useInternalNodes = TRUE,trim=F) 
  years <- xpathSApply(pagetree,'//*/form[@name="daily"]/select[@name="year"]/option',xmlValue)
  years  <- as.numeric(years)
  minYear  <- min(years)
  maxYear <- max(years)
  #if(year.start < minYear || year.end >maxYear){
  #  stop("invalid time interval,max year is\t",maxYear,"min year is\t" ,minYear)
  #}
  
  if(year.start < minYear){
    year.start <<- minYear
  }
  
  if(year.end >maxYear){
    year.end <<- maxYear
  }
  
}

###主函数
#'@param code  股票代码在沪深交易所网站课直接获得
#'@param year.start 起始年
#'@param 终止年
#'@param path 保存到的文件路径，直接输入文件名则保存在工作目录下
#'@return  不凡任何值，直接将数据写入path中（直接读取会出现错误）
getAllInfo.TQ  <- function(code,year.start,year.end,myheader,path){
#  code = 600000
#  year.start  = 1980
#  year.end =2015
#  path = paste(code,"csv",sep=".")
  
  verifyYears(code,year.start,year.end,myheader)
  
  years =seq(from = year.start,to = year.end,by = 1);
  urls  <- paste("http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/",
                 as.character(code),".phtml?year=",years,sep="");
  res <- ldply(urls,getSingleInfo.TQ,myheader,.progress =  "win")
  names(res) <- c("date","open","high","close","low","volume","total_pay")
  write.csv(res,path)
  
  #释放内存
  rm(urls, res)
  gc()
  
}
getSingleInfo.TQ  <- function(page,myheader){
  force(page)
  pages  <<- paste(page,"&jidu=",1:4,sep="")
  ldply(pages,failwith(f=readTable,quiet = T),myheader)
  
} 
readTable  <- function (url,myheader){
  force(url)
  webpage <- getURL(url,httpheader = myheader,.encoding='UFT-8',curl = handle)
  pagetree <- htmlTreeParse(webpage,encoding="UFT-8", error=function(...){}, useInternalNodes = TRUE,trim=F) 
  table  <- readHTMLTable(pagetree,header = F)
  table  <- table$FundHoldSharesTable[-c(1,2),]
  n  <- nrow(table)
  table[rev(1:n),]
  
}

myheader=c("User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0",
           "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
           "Accept-Language"="zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
           "Connection"="keep-alive",
           "Accept-Charset"="GB2312,utf-8;q=0.7,*;q=0.7"
)

handle <- getCurlHandle()



############使用样例
####直接调用getAllInfo.TQ即可

library(RODBC)
channel_sh<-odbcConnect("MySQL",uid="root",pwd="77297729")
stockBaseInfo <- sqlFetch(channel_sh,"STOCK_CODE_SH")
odbcClose(channel_sh)



#code <- "600870"
#getAllInfo.TQ(code = code,year.start  = 2015,year.end =2015,myheader,paste(code,"csv",sep="."))

#skip code: no
#
gcinfo(FALSE)

#Download data for SH
setwd("E:\\R\\MyStudy\\stockdata")
#600870 
#for(code in as.character(stockBaseInfo$productid[stockBaseInfo$productid > 600870])) {
for(code in as.character(stockBaseInfo$code[stockBaseInfo$code == 600870])) {
  print(code)
  getAllInfo.TQ(code = as.character(code),year.start  = 2015,year.end =2015,myheader,paste(code,"csv",sep="."))
  
}


#Download data for SZ


SZ_Stock <- read.delim("E:/R/MyStudy/SZ_Stock.txt",dec = ",",colClasses="character")
names(SZ_Stock) <- c("CODE","COMPANY_ABBR","COMPANY_FULL_NAME","ENGLISH_NAME","ADDR","A_CODE","A_ABBR",
                     "A_OFFER_DATE","A_CAPITAL","A_SHARES_CAPITAL","B_CODE","B_ABBR"
                     ,"B_OFFER_DATE","B_CAPITAL","B_SHARES_CAPITAL","REGION","PROVINCE","CITY","INDUSTRY","WEB_SITE")


setwd("E:\\R\\MyStudy\\stockdata")
for(code in SZ_Stock$CODE[SZ_Stock$A_CODE != "" & SZ_Stock$CODE > '002738' & SZ_Stock$CODE < "300164"]){
  print(code)
  getAllInfo.TQ(code = as.character(code),year.start  = 1980,year.end =2015,myheader,paste(code,"csv",sep="."))

}


