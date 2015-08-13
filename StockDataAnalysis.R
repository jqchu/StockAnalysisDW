library(RODBC)
library(RColorBrewer)

channel<-odbcConnect("MySQL",uid="root",pwd="77297729")

info <- sqlFetch(channel, "hq_staging")

info <- info[,c(-23,-24)]

odbcClose(channel)

setwd("E:\\R\\MyStudy\\graphic")
#==============图1 沪深市场概况 ================

#统计上海A般，深圳A股，中小板，创业板股票数据，以及上涨，平盘及下跌的股票数据

info$code <- substr(info$symbol,3,9)
rm(info$type)
info$type[substr(info$code,1,2) == "60"] <- 1
info$type[substr(info$code,1,2)=="00" & substr(info$code,1,3) !="002"] <- 2
info$type[substr(info$code,1,3)=="002"] <- 3
info$type[substr(info$code,1,3)=="300"] <- 4
info$type <- factor(info$type,levels = c(1,2,3,4),labels = c("上海A股","深圳A股","中小板","创业板"))

#统计股票数据
stockCount <- table(info$type)
pielabels <- sprintf("%s(%d)",names(stockCount), stockCount)
pie(stockCount, main="沪深市场概况", labels = pielabels, 
    clockwise = FALSE,radius = 1,col = brewer.pal(4,"Set1"),border = "white", cex = 0.8)


#================图1结束===============================


#==============图2 沪深市场股票涨跌情况================



info <- info[info$changepercent > 5,]
plot(y=info$volume,x=info$changepercent,axes = TRUE, xlim=c(-15,15),type="n")
axis(1,at=c(seq(-15,15,by=1)))

#在x轴上添加日期刻度
#text(x=1:nrow(info), y=0, labels=info$code, cex=0.75,srt=60)
#在对应点上添加记录条数
text(y=info$volume,x=info$changepercent, info$code, cex=0.7, col=rainbow(50))

#
pairs(info[,4:11], col=c(1:20))

barplot(as.matrix(info[1:3,4:11]), beside=TRUE,
        legend=info$code,
        col=heat.colors(5),
        border="white")

hist(info$trade)
hist(info$changepercent)




oInfo <- order(info$changepercent,decreasing = TRUE)
changeInfo <- info[c(head(oInfo,n=50),tail(oInfo,n=50)),]

changeInfo$col12[changeInfo$pricechange > 0 ] <- 2
changeInfo$col12[changeInfo$pricechange < 0 ] <- 3
barplot(changeInfo$changepercent, col=changeInfo$col12, border = "white")


library(RColorBrewer)
display.brewer.all()
brewer.pal(11,"RdYlGn")



boxplot(info$trade,
        xlab="Info",
        ylab="digital",
        main="stock price")