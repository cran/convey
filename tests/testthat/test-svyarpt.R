context("Arpt output")
library(vardpoor)
data(eusilc) ; names( eusilc ) <- tolower( names( eusilc ) )
dati = data.frame(1:nrow(eusilc), eusilc)
colnames(dati)[1] <- "IDd"
SE_lin2 <- function(t,des){
  variance<-survey::svyrecvar(t/des$prob, des$cluster,des$strata, des$fpc,postStrata = des$postStrata)
  sqrt(variance)
}
des_eusilc <- svydesign(ids = ~rb030, strata =~db040,  weights = ~rb050, data = eusilc)

des_eusilc <- convey_prep(des_eusilc)
dati <- data.frame(IDd = 1:nrow(eusilc), eusilc)
vardpoor_arptw <- linarpt(Y = "eqincome", id = "IDd", weight = "rb050", Dom = NULL, dataset = dati, percentage = 60, order_quant = 50)

vardest<- vardpoor_arptw$value
attributes(vardest)<- NULL
vardest<- unlist(vardest)
varse<- SE_lin2(vardpoor_arptw$lin$lin_arpt, des_eusilc)
attributes(varse)<- NULL
fun_arptw <- svyarpt(~eqincome, design = des_eusilc, 0.5, 0.6)
convest<-coef(fun_arptw)
attributes(convest)<-NULL
convse<- SE(fun_arptw)
attributes(convse)<-NULL

#domain
vardpoor_arptd <- linarpt(Y = "eqincome", id = "IDd", weight = "rb050", Dom = "db040",
  dataset = dati, percentage = 60, order_quant = 50)
#  point estimates
vardestd<-unlist(vardpoor_arptd$value$threshold)
#  se estimates
varsed<-sapply(data.frame(vardpoor_arptd$lin)[,2:10],function(t) SE_lin2(t,des_eusilc))
attributes (varsed) <- NULL
# library convey
fun_arptd <- svyby(~eqincome, by = ~db040, design = des_eusilc, FUN = svyarpt, order = 0.5,percent = 0.6,deff = FALSE)
convestd<- coef(fun_arptd)
attributes(convestd) <- NULL
convsed<- SE(fun_arptd)

test_that("compare results convey vs vardpoor",{
  expect_equal(vardest, convest)
  expect_equal(varse, convse)
  expect_equal(vardestd, convestd)
  expect_equal(varsed, convsed)
})