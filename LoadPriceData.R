library(RODBC)

setwd("E:\\R\\MyStudy\\stockdata")


channel_sz<-odbcConnect("MySQL",uid="root",pwd="77297729")
files <- list.files()
for (file in files){
  info <- read.csv(file)
  info$code = substr(file,1,6)
  
  info2 <- data.frame(DATE=info$date,
                      CODE=info$code,
                      OPEN=info$open ,
                      HIGH=info$high ,
                      CLOSE=info$close ,
                      LOW=info$low ,
                      VOLUME=info$volume ,
                      TOTAL_PAY=info$total_pay)
  
  sqlDrop(channel_sz,"stock_trans_info_staging")
  sqlSave(channel_sz,info2, "stock_trans_info_staging",append = FALSE,rownames = FALSE)
  
  sqlStr <- "insert into stock_trans_info
             select date, code, code, open, high, close, low, volume, total_pay,
                    current_timestamp as CREATE_TIME,
                    current_timestamp as UPDATE_TIME 
             from stock_trans_info_staging"
  
  sqlQuery(channel_sz, sqlStr)

}


odbcClose(channel_sz)