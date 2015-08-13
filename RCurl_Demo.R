library("bitops")
library("XML")
library("RCurl")
library(rjson)


myheader=c(Host: query.sse.com.cn
           User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0
           Accept: */*
             Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3
           Accept-Encoding: gzip, deflate
           Referer: http://www.sse.com.cn/assortment/stock/list/name/
             Connection: keep-alive
)

url_01 <- "http://datainterface.eastmoney.com/EM_DataCenter/JS.aspx?type=FD&sty=TSTC&st=1&sr=1&p=57&ps=50&js=var%20RDDFYlFT=(x)&mkt=0&rt=47795311"
page01 <- getURL(url_01)


url_02 <- "http://datainterface.eastmoney.com/EM_DataCenter/JS.aspx?type=FD&sty=TSTC&st=1&sr=1&p=2&ps=50&js=var%20thTWMCkx=%28x%29&mkt=1&rt=47795139"
page02 <- getURL(url_02)

#从上海证交所获取信息
header02 <- c("Host"="query.sse.com.cn",
  "User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0",
  "Accept"="*/*",
  "Accept-Language"="zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
  "Accept-Encoding"="gzip, deflate",
  "Referer"="http://www.sse.com.cn/assortment/stock/list/name/",
  "Connection"="keep-alive"
)

url03 <- "http://query.sse.com.cn/commonQuery.do?jsonCallBack=jsonpCallback90870&isPagination=true&sqlId=COMMON_SSE_ZQPZ_GPLB_MCJS_SSAG_L&pageHelp.pageSize=500&pageHelp.pageNo=1&pageHelp.beginPage=1&pageHelp.endPage=5&_=1433863568061"

page03 <- getURL(url03, httpHeader=header02)

temp <- substring(page03,20);
jsonData <- fromJSON(temp)

length(jsonData)

names(jsonData)

names(jsonData$pageHelp)

#显示页数
jsonData$pageHelp
jsonData$pageHelp$data[29:30]
str(jsonData$pageHelp)
for (x in jsonData$pageHelp$data) {
  info <- paste(x$NUM, x$FULLNAME, x$PRODUCTNAME, x$PRODUCTID,sep=",")
  print(info)

}




