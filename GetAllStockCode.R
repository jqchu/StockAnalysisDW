library(bitops)
library(RCurl)
library(XML)
library(RCurl)
library(rjson)
library(RODBC)

#
#从深圳证券交易所获取信息
#
getStockCodeSZ <- function(){

	header <- c("Host"=" www.szse.cn",
				  "User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0",
				  "Accept"="*/*",
				  "Accept-Language"="zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
				  "Accept-Encoding"="gzip, deflate",
				  "Referer"="http://www.sse.com.cn/assortment/stock/list/name/",
				  "Connection"="keep-alive"
	)

	url <- "http://www.szse.cn/szseWeb/FrontController.szse?ACTIONID=8&CATALOGID=1110&tab2PAGENUM=1&ENCODE=1&TABKEY=tab2"
	page03 <- getURL(url, httpHeader=header,.encoding = "GBK")
	k = iconv(page03, 'GBK', 'utf-8')
	doc = htmlParse(k, encoding="utf-8")
	tables <-readHTMLTable(doc)

	names(tables$REPORTID_tab2) <- c('code','company_abbr','company_full_name','english_name','addr','a_code','a_abbr','a_offer_date','a_capital','a_shares_capital','b_code','b_abbr','b_offer_date','b_capital','b_shares_capital','region','province','city','industry','web_site')

	return (tables$REPORTID_tab2)
}

#
#从上海证交所获取信息
#
getStockCodeSH <- function(){
	header <- c("Host"="query.sse.com.cn",
				  "User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0",
				  "Accept"="*/*",
				  "Accept-Language"="zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
				  "Accept-Encoding"="gzip, deflate",
				  "Referer"="http://www.sse.com.cn/assortment/stock/list/name/",
				  "Connection"="keep-alive"
	)

	url <- "http://query.sse.com.cn/commonQuery.do?jsonCallBack=jsonpCallback90870&isPagination=true&sqlId=COMMON_SSE_ZQPZ_GPLB_MCJS_SSAG_L&pageHelp.pageSize=300&pageHelp.pageNo=1&pageHelp.beginPage=1&pageHelp.endPage=5&_=1433863568061"
	page <- getURL(url, httpHeader=header)
	page <- substring(page,20);
	jsonData <- fromJSON(page)

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

	names(info) <- c("NUM","company_full_name","company_abbr","code")
	return (info)
}


#
#Main Write the stock data into MySQL
#

channel<-odbcConnect("MySQL",uid="root",pwd="123456")
sqlQuery(channel,"DELETE FROM stock_dw.stock_code where left(code,2) <> '60'")

#process SZ stock data
info <- getStockCodeSZ()
sqlProcessStatement <- "insert into `stock_dw`.`stock_code`(`code`,`company_abbr`,`company_full_name`,`english_name`,`addr`,`a_code`,`a_abbr`,`a_offer_date`,`a_capital`,`a_shares_capital`,`b_code`,`b_abbr`,`b_offer_date`,`b_capital`,`b_shares_capital`,`region`,`province`,`city`,`industry`,`web_site`) values("

for (i in 1:nrow(info)){
  sql <-paste("'",info[i,1],"',",
              "'",info[i,2],"',",
              "'",info[i,3],"',",
              "'",info[i,4],"',",
              "'",info[i,5],"',",
              "'",info[i,6],"',",
              "'",info[i,7],"',",
              "'",info[i,8],"',",
              "'",info[i,9],"',",
              "'",info[i,10],"',",
              "'",info[i,11],"',",
              "'",info[i,12],"',",
              "'",info[i,13],"',",
              "'",info[i,14],"',",
              "'",info[i,15],"',",
              "'",info[i,16],"',",
              "'",info[i,17],"',",
              "'",info[i,18],"',",
              "'",info[i,19],"',",
              "'",info[i,20],"'",sep="")
  sqlQuery(channel,paste(sqlProcessStatement,sql,")",sep=""))
}


#process SH stock data
info <- getStockCodeSH()
sqlQuery(channel,"DELETE FROM stock_dw.stock_code where left(code,2) = '60'")
sqlProcessStatement <-'INSERT INTO `stock_dw`.`stock_code`(`company_full_name`,  `company_abbr`,  `code`) values('
sql <- ""
for(i in 1:nrow(info)){
  sql <-paste("'",info[i,2],"',",
              "'",info[i,3],"',",
              "'",info[i,4],"'",sep="")
  sqlQuery(channel,paste(sqlProcessStatement,sql,")",sep=""))
}


odbcClose(channel)

