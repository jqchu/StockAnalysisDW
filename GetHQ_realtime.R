library(bitops)
library(RCurl)
library(XML)

#
# This scripts used to get the latest Price data every 5 senods.
#
#

myheader<- c("Host"="hq.sinajs.cn",
             "User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20100101 Firefox/31.0",
             "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
             "Accept-Language"="en-US,en;q=0.5",
             "Accept-Encoding"="gzip, deflate",
             "Connection"="keep-alivehq.sinajs.cn"
)


mycurl = getCurlHandle()

code <- "sh601857"
while (1 == 1) {
  
  url <- paste("http://hq.sinajs.cn/list=",code,sep="")
  info <- getURL(url, .encoding="gb2312", curl=mycurl )
  info2 <- iconv(info,"gb2312","UTF-8")
  print(info2)
  writeLines("")
  writeLines("")

  Sys.sleep(5)
  
}



