library(bitops)
library(RCurl)
library(rjson)
library(RODBC)
library(ggplot2)

setwd("E:\\R\\MyStudy\\")

GetHQData <- function(){
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
    #print(url)
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
  
  hs_a
}



myplot <- function(info){
  #设置过滤条件
  #info <- stockData[stockData$changepercent > 5 | stockData$changepercent < -5,]
  #交易额(亿)
info$amountOK= info$amount / 100000000
  
  #资金流入或流出金额
  #info$tradeAjust <- info$trade
#info[info$trade==0,]$tradeAjust <- info[info$trade ==0,]$settlement
  #info$mncChange <- (info$nmc * 10000 / info$tradeAjust) * (info$tradeAjust - info$settlement) / 1000000000
  
  #设置颜色(亿)
info$color[info$changepercent >= 0] <- 2
  info$color[info$changepercent < 0] <- 3
 
  #设置X轴坐标
plot(y=info$changepercent,x=info$amountOK,axes = TRUE, type="n",  main="沪深个股分布", ylab="涨跌幅度",xlab="交易额(亿)")
axis(2,at=c(seq(-11,11,by=1)))
  
  #设置文本标签
#sLable <- paste(sprintf("%s(%3.2f",info$name, info$amountOK),"亿)",sep="")
sLable <- paste(sprintf("%s(%3.2f",info$name, info$amountOK),"亿)",sep="")
text(x=info$amountOK,y=info$changepercent, sLable, cex=0.7, col=info$color, adj=c(0,1))
  

}

#制作热力图
mymap <- function(info){
  #设置过滤条件
  #info <- stockData[stockData$changepercent > 5 | stockData$changepercent < -5,]
  
Hight20 <- info[1:20,]
infomap <- as.matrix(Hight20[,c(4:9)])
  rownames(infomap) <- Hight20$symbol
  infoHeatColor <- infomap$
heatmap(infomap,Rowv=NA, Colv=NA, heat.colors(256))
}

plotSplit <-function(){
info60 <- info[substr(info$code,1,2)== "60",]
info00 <- info[substr(info$code,1,2)=="00" & substr(info$code,1,3) !="002",]
info002 <- info[substr(info$code,1,3)=="002",]
info300 <- info[substr(info$code,1,3)== '300',]
  
  myplot(info60)
  myplot(info00)
  myplot(info002)
  myplot(info300)
}

mygplot <- function(info, title){
  
  amountUnit <- 100000000 #单位: 亿
  info$codeLable <- sprintf("%s(%3.2f)",info$name,info$amount/amountUnit)

  p <- ggplot(info, main=title) + geom_blank()

  tart <- p + geom_text(aes(x=amount,y= changepercent, label=codeLable,size=3, colour=changepercent)) + labs(title=title)
  print(tart)

}




while(TRUE){
  print(Sys.time())
  
  info <- GetHQData()
 
  info60 <- info[substr(info$code,1,2)== "60",]
  info00 <- info[substr(info$code,1,2)=="00" & substr(info$code,1,3) !="002",]
  info002 <- info[substr(info$code,1,3)=="002",]
  info300 <- info[substr(info$code,1,3)== '300',] 

  #mygplot(info60, "沪市A股")
  #mygplot(info00, "深市A股")
  #mygplot(info002, "中小板")
  mygplot(info300,"创业板")
  writeLines("")
  Sys.sleep(60)
}
