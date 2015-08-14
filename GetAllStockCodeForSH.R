#GetAllStockCode
#This scripts used to get stock data from Shanghai sse.com.cn
#Output 1： E:\\R\\MyStudy
#Output 2:  MySQL DB:stock_dw.STOCK_CODE_SH

library("bitops")
library("XML")
library("RCurl")
library(rjson)

library(zoo)
library(xts)
library(quantmod)

setwd("E:\\R\\MyStudy")

#get stock data base info from see.com.cn 
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

#Output: put the data into mysql
library(RODBC)
channel_sh<-odbcConnect("MySQL",uid="root",pwd="root")
sqlQuery(channel_sh,"DROP TABLE IF EXISTS STOCK_CODE_SH_STAGING")
sqlSave(channel_sh, info,"STOCK_CODE_SH_STAGING",rownames=FALSE)

odbcClose(channel_sh)



