## ----results='hide', message=FALSE, warning=FALSE------------------------
library(vardpoor)
data(eusilc)

## ----results='hide', message=FALSE, warning=FALSE------------------------
library(survey)
des_eusilc <- svydesign(ids = ~rb030, strata =~db040,  weights = ~rb050, data = eusilc)

## ------------------------------------------------------------------------
library(convey)
des_eusilc <- convey_prep( des_eusilc )

## ----comment=NA----------------------------------------------------------
svyarpr(~eqIncome, design=des_eusilc)

## ----comment=NA----------------------------------------------------------
svyby(~eqIncome, by = ~db040, design = des_eusilc, FUN = svyarpr, deff = FALSE)

## ----comment=NA----------------------------------------------------------
# for the whole population
svyqsr(~eqIncome, design=des_eusilc, alpha= .20)

# for domains
svyby(~eqIncome, by = ~db040, design = des_eusilc,
  FUN = svyqsr, alpha= .20, deff = FALSE)


## ------------------------------------------------------------------------
des_eusilc_rep <- as.svrepdesign(des_eusilc, type = "bootstrap")
des_eusilc_rep <- convey_prep(des_eusilc_rep) 

## ----comment=NA----------------------------------------------------------
svyarpr(~eqIncome, design=des_eusilc_rep)
svyby(~eqIncome, by = ~db040, design = des_eusilc_rep, FUN = svyarpr, deff = FALSE)

## ----comment=NA----------------------------------------------------------
# survey.design using a variable with missings
svygini( ~ py010n , design = des_eusilc )
svygini( ~ py010n , design = des_eusilc , na.rm = TRUE )
# svyrep.design using a variable with missings
# svygini( ~ py010n , design = des_eusilc_rep ) get error
svygini( ~ py010n , design = des_eusilc_rep , na.rm = TRUE )

## ----comment=NA----------------------------------------------------------
svyfgt(~eqIncome, des_eusilc, g=0, abs_thresh=10000)

## ----comment=NA----------------------------------------------------------
svyfgt(~eqIncome, des_eusilc, g=1, abs_thresh=10000)

## ----comment=NA----------------------------------------------------------
svyfgt(~eqIncome, des_eusilc, g=0, type_thresh= "relq")

## ----comment=NA----------------------------------------------------------
svyarpr(~eqIncome, design=des_eusilc, .5, .6)

## ----comment=NA----------------------------------------------------------
svyfgt(~eqIncome, des_eusilc, g=1, type_thresh= "relm")

