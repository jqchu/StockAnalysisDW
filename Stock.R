library(xts)
library(tseries)


GSPC <- as.xts(get.hist.quote(instrument='601398.ss',start='2014-01-01',,quote=c("Open","High","Low","Close","Volum","AdjClose")))

GSPC



