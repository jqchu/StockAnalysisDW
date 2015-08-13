library(RCurl)
library(rjson)
library(RODBC)

setwd("E:\\R\\MyStudy\\")
#从新浪
header=c("User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0",
         "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
         "Accept-Language"="zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
         "Connection"="keep-alive",
         "Accept-Charset"="GB2312,utf-8;q=0.7,*;q=0.7"
)


GetInfo <- function (url){
  page <- getURL(url, httpHeader=header)
  
  # "/*<script>location.href='//sina.com';</script>*/\nFDC_DC.theTableData([{\"code\":0
  temp <- substring(page,71);
  jsonData <- fromJSON(temp)
  
  #jsonData$code
  #jsonData$fields
  #jsonData$count
  
  
  pageData <- data.frame()
  for(item in jsonData$items){
    temp <- as.data.frame(item, stringsAsFactors=FALSE)
    names(temp) <- jsonData$fields
    pageData <- rbind(pageData, temp)
  }
  
  pageData
}

#old:URLhttp://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=1&num=80&sort=symbol&asc=1&node=hs_a&symbol=&_s_r_a=init
hs_a <- data.frame()

for(i in c(1:40)){
  url <- paste("http://money.finance.sina.com.cn/d/api/openapi_proxy.php/?__s=[[%22hq%22,%22hs_a%22,%22%22,0,",i,",80]]&callback=FDC_DC.theTableData",sep="")
  print(url)
  hs_a <- rbind(hs_a,GetInfo(url))
}

hs_a$trade <-as.numeric(hs_a$trade)
hs_a$pricechange <-as.numeric(hs_a$pricechange)
hs_a$changepercent <-as.numeric(hs_a$changepercent)
hs_a$buy <-as.numeric(hs_a$buy)
hs_a$sell <-as.numeric(hs_a$sell)
hs_a$settlement <-as.numeric(hs_a$settlement)
hs_a$open <-as.numeric(hs_a$open)
hs_a$high <-as.numeric(hs_a$high)
hs_a$low <-as.numeric(hs_a$low)
hs_a$volume <-as.numeric(hs_a$volume)
hs_a$amount <-as.numeric(hs_a$amount)
hs_a$nta <-as.numeric(hs_a$nta)



hs_a$date <- as.character(Sys.Date())

#write.csv(hs_a, paste("HQ",Sys.Date(),sep=""))
          
#Store the data into MySQL DB. 

channel_hs<-odbcConnect("MySQL",uid="root",pwd="77297729")
sqlDrop(channel_hs,"stock_dw.hq_staging")
sqlSave(channel_hs,hs_a, "stock_dw.hq_staging", rownames = FALSE)

sqlstr <- "call insert_hq_hist()"
sqlQuery(channel_hs,sqlstr)

odbcClose(channel_hs)










