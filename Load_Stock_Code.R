library(RODBC)
library(ggplot2)


channel<-odbcConnect("MySQL",uid="root",pwd="77297729")

setwd("E:\\R\\MyStudy")
SZ_Stock <- read.delim("E:/R/MyStudy/SZ_Stock.txt",dec = ",")

nrow(SZ_Stock)

names(SZ_Stock) <- c("CODE","COMPANY_ABBR","COMPANY_FULL_NAME","ENGLISH_NAME","ADDR","A_CODE","A_ABBR",
                     "A_OFFER_DATE","A_CAPITAL","A_SHARES_CAPITAL","B_CODE","B_ABBR"
                     ,"B_OFFER_DATE","B_CAPITAL","B_SHARES_CAPITAL","REGION","PROVINCE","CITY","INDUSTRY","WEB_SITE")



sqlSave(channel, SZ_Stock,"STOCK_CODE_BASE_INFO5",rownames=FALSE)


odbcClose(channel)
