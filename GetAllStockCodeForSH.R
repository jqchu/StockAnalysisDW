#GetAllStockCode
#本程序类用RCURL从上海证券交易所网站上抓取沪市证券股票代码
#输出1： 将所抓取的结果输入到E:\\R\\MyStudy\\Stock_info2.csv
#输入2:  MySQL DB:stock_dw.STOCK_CODE_SH

library("bitops")
library("XML")
library("RCurl")
library(rjson)

library(zoo)
library(xts)
library(quantmod)

#自定义函数,获取股票历史数据
getHistoryPrice <- function(x){
  #
  
}


setwd("E:\\R\\MyStudy")

#从上海证交所获取信息
header02 <- c("Host"="query.sse.com.cn",
              "User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0",
              "Accept"="*/*",
              "Accept-Language"="zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
              "Accept-Encoding"="gzip, deflate",
              "Referer"="http://www.sse.com.cn/assortment/stock/list/name/",
              "Connection"="keep-alive"
)

url03 <- "http://query.sse.com.cn/commonQuery.do?jsonCallBack=jsonpCallback90870&isPagination=true&sqlId=COMMON_SSE_ZQPZ_GPLB_MCJS_SSAG_L&pageHelp.pageSize=300&pageHelp.pageNo=1&pageHelp.beginPage=1&pageHelp.endPage=5&_=1433863568061"
page03 <- getURL(url03, httpHeader=header02)
temp <- substring(page03,20);
jsonData <- fromJSON(temp)

info <- data.frame(NUM=numeric(),FULLNAME=numeric(),NAME=numeric(),CODE=numeric())
i <- 1;
for (x in jsonData$pageHelp$data) {
  #info[i] <- paste(x$NUM, x$FULLNAME, x$PRODUCTNAME, x$PRODUCTID,sep=",")
  
  info[i,"NUM"] <- x$NUM
  info[i,"FULLNAME"] <- x$FULLNAME
  info[i,"NAME"] <- x$PRODUCTNAME
  info[i,"CODE"] <- x$PRODUCTID
  
  i <- i + 1
}

names(info) <- c("NUM","FULLNAME","NAME","CODE")

#输出: 将数据写入到MYSQL数据库
library(RODBC)
channel_sh<-odbcConnect("MySQL",uid="root",pwd="77297729")
sqlQuery(channel_sh,"DROP TABLE IF EXISTS STOCK_CODE_SH_STAGING")
sqlSave(channel_sh, info,"STOCK_CODE_SH_STAGING",rownames=FALSE)


odbcClose(channel_sh)



