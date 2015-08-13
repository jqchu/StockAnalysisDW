library(RCurl)
library(XML)
page <- getURL("http://f10.eastmoney.com/f10_v2/CompanySurvey.aspx?code=sz002017")
treepage <- htmlTreeParse(page)


pagetree <- htmlTreeParse(page,encoding="utf-8", error=function(...){}, useInternalNodes = TRUE,trim=F) 
#a <- xpathSApply(pagetree,'//*/table[@id="Table0"]',xmlValue)

tables <- readHTMLTable(pagetree, header = FALSE)