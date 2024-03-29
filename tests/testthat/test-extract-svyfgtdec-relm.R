# load libraries
library(survey)
library(laeken)
# library( vardpoor )

# return test context
context("svyfgtdec-relm decomposition output survey.design and svyrep.design")

### test 2: income data from eusilc --- data.frame-backed design object

# collect and format data
data(eusilc)
names(eusilc) <- tolower(names(eusilc))

# set up survey design objects
des_eusilc <-
  svydesign(
    ids = ~ rb030 ,
    strata = ~ db040 ,
    weights = ~ rb050 ,
    data = eusilc
  )
des_eusilc_rep <-
  as.svrepdesign(des_eusilc , type = "bootstrap" , replicates = 50)

# prepare for convey
des_eusilc <- convey_prep(des_eusilc)
des_eusilc_rep <- convey_prep(des_eusilc_rep)

# remove groups with zero observations
des_eusilc <- subset( des_eusilc , hsize < 7 )
des_eusilc_rep <- subset( des_eusilc_rep , hsize < 7 )

# test "deff not implemented" error
expect_error(
  svyfgtdec(
    ~ eqincome ,
    des_eusilc ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    linearized = TRUE ,
    deff = TRUE
  )
)

# calculate estimates
a1 <-
  svyfgtdec(
    ~ eqincome ,
    des_eusilc ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    linearized = TRUE ,
    deff = FALSE
  )
a2 <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc ,
    svyfgtdec ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    covmat = FALSE # should be TRUE once we find a way to deal with full_design in svyby
  )
a2.nocov <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc ,
    svyfgtdec ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    covmat = FALSE
  )
b1 <-
  svyfgtdec(
    ~ eqincome ,
    des_eusilc_rep ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    linearized = TRUE
  )
b2 <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc_rep ,
    svyfgtdec ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    covmat = TRUE
  )
b2.nocov <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc_rep ,
    svyfgtdec ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    covmat = FALSE
  )
d1 <-
  svyfgt(
    ~ eqincome ,
    des_eusilc ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE
  )
d2 <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc ,
    svyfgt ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE
  )
e1 <-
  svyfgt(
    ~ eqincome ,
    des_eusilc ,
    g = 0 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE
  )
e2 <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc ,
    svyfgt ,
    g = 0 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE
  )
f1 <-
  svyfgt(
    ~ eqincome ,
    des_eusilc ,
    g = 1 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE
  )
f2 <-
  svyby(
    ~ eqincome ,
    ~ hsize,
    des_eusilc ,
    svyfgt ,
    g = 1 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE
  )

# calculate auxilliary tests statistics
cv_diff1 <- max(abs(cv(a1) - cv(b1)))
se_diff2 <- max(abs(SE(a2) - SE(b2)) , na.rm = TRUE)

# perform tests
test_that("output svyfgtdec" , {
  expect_is(coef(a1) , "numeric")
  expect_is(coef(a2) , "numeric")
  expect_is(coef(b1) , "numeric")
  expect_is(coef(b2) , "numeric")
  expect_equal(coef(a1) , coef(b1))
  expect_equal(coef(a2) , coef(b2))
  # expect_lte( cv_diff1 , (coef(a1)[[1]]) * 0.05 )         # the difference between CVs should be less than 5% of the coefficient, otherwise manually set it
  expect_lte(se_diff2 , max(coef(a2)) * 0.05) # the difference between CVs should be less than 10% of the maximum coefficient, otherwise manually set it
  expect_equal(sum(confint(a2)[, 1] <= coef(a2)) , length(coef(a2)))
  expect_equal(sum(confint(a2)[, 2] >= coef(a2)) , length(coef(a2)))
  expect_equal(sum(confint(b2)[, 1] <= coef(b2)) , length(coef(b2)))
  expect_equal(sum(confint(b2)[, 2] >= coef(b2)) , length(coef(b2)))
  expect_equal(coef(a1)[[1]] , coef(d1)[[1]])
  expect_equal(SE(a1)[[1]] , SE(d1)[[1]])
  expect_equal(coef(a1)[[2]] , coef(e1)[[1]])
  expect_equal(SE(a1)[[2]] , SE(e1)[[1]])
  expect_equal(coef(a1)[[3]] , coef(f1)[[1]])
  expect_equal(SE(a1)[[3]] , SE(f1)[[1]])

  # check equality of linearized variables
  expect_equal(attr(a1 , "linearized") , attr(b1 , "linearized"))
  expect_equal(attr(a1 , "index") , attr(b1 , "index"))

  # check equality vcov diagonals
  expect_warning(expect_equal(diag(vcov(a2)) , diag(vcov(a2.nocov))))
  expect_warning(expect_equal(diag(vcov(b2)) , diag(vcov(b2.nocov))))

})

### test 2: income data from eusilc --- database-backed design object

# perform tests
test_that("database svyfgtdec", {
  # skip test on cran
  skip_on_cran()

  # load libraries
  library(RSQLite)
  library(DBI)

  # set-up database
  dbfile <- tempfile()
  conn <- dbConnect(RSQLite::SQLite() , dbfile)
  dbWriteTable(conn , 'eusilc' , eusilc)

  # database-backed design
  dbd_eusilc <-
    svydesign(
      ids = ~ rb030 ,
      strata = ~ db040 ,
      weights = ~ rb050 ,
      data = "eusilc",
      dbname = dbfile,
      dbtype = "SQLite"
    )

  # prepare for convey
  dbd_eusilc <- convey_prep(dbd_eusilc)

  # remove groups with zero observations
  dbd_eusilc <- subset( dbd_eusilc , hsize < 7 )

  # calculate estimates
  c1 <-
    svyfgtdec(
      ~ eqincome ,
      dbd_eusilc ,
      g = 2 ,
      percent = .6 ,
      type_thresh = "relm" ,
      deff = FALSE ,
      linearized = TRUE
    )
  c2 <-
    svyby(
      ~ eqincome ,
      ~ hsize,
      dbd_eusilc ,
      svyfgtdec ,
      g = 2 ,
      percent = .6 ,
      type_thresh = "relm" ,
      deff = FALSE ,
      covmat = FALSE # should be TRUE once we find a way to deal with full_design in svyby
    )

  # remove table and close connection to database
  dbRemoveTable(conn , 'eusilc')
  dbDisconnect(conn)

  # peform tests
  expect_equal(coef(a1) , coef(c1))
  expect_equal(coef(a2) , coef(c2)[match(names(coef(c2)) , names(coef(a2)))])
  expect_equal(SE(a1) , SE(c1))
  expect_equal(SE(a2) , SE(c2))
  # expect_equal(deff(a1) , deff(c1))
  # expect_equal(deff(a2) , deff(c2)[2:1 ,])

  # check equality of linearized variables
  expect_equal(attr(c1 , "linearized") , attr(a1 , "linearized"))
  expect_equal(attr(c1 , "index") , attr(a1 , "index"))

})

### test 3: compare subsetted objects to svyby objects

# calculate estimates
sub_des <-
  svyfgtdec(
    ~ eqincome ,
    design = subset(des_eusilc , hsize == 1) ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    linearized = TRUE
  )
sby_des <-
  svyby(
    ~ eqincome,
    by = ~ hsize,
    design = des_eusilc,
    FUN = svyfgtdec ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    covmat = FALSE # should be TRUE once we find a way to deal with full_design in svyby
  )
sub_rep <-
  svyfgtdec(
    ~ eqincome ,
    design = subset(des_eusilc_rep , hsize == 1) ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    linearized = TRUE
  )
sby_rep <-
  svyby(
    ~ eqincome,
    by = ~ hsize,
    design = des_eusilc_rep,
    FUN = svyfgtdec ,
    g = 2 ,
    percent = .6 ,
    type_thresh = "relm" ,
    deff = FALSE ,
    covmat = TRUE
  )

# perform tests
test_that("subsets equal svyby", {
  # domain vs svyby: coefficients must be equal
  expect_equal(as.numeric(coef(sub_des)) , as.numeric(coef(sby_des[1, ])))
  expect_equal(as.numeric(coef(sub_rep)) , as.numeric(coef(sby_rep[1, ])))

  # domain vs svyby: SEs must be equal
  expect_equal(as.numeric(SE(sub_des)) , as.numeric(SE(sby_des[1, ])))
  expect_equal(as.numeric(SE(sub_rep)) , as.numeric(SE(sby_rep[1, ])))

  # domain vs svyby and svydesign vs svyrepdesign:
  # coefficients should match across svydesign
  expect_equal(as.numeric(coef(sub_des)) , as.numeric(coef(sby_rep[1, ])))

  # domain vs svyby and svydesign vs svyrepdesign:
  # coefficients of variation should be within five percent
  cv_diff <- max(abs(cv(sub_des) - cv(sby_rep)[1, ]))
  expect_lte(cv_diff , .05)

  # check equality of linearized variables
  expect_equal(attr(sub_des , "linearized") , attr(sub_rep , "linearized"))

  # check equality of variances
  expect_warning(expect_equal(vcov(sub_des)[1] , vcov(sby_des)[1, 1]))
  expect_equal(vcov(sub_rep)[1] , vcov(sby_rep)[1, 1])

})

### test 4: compare subsetted objects to svyby objects

# compare database-backed designs to non-database-backed designs
test_that("dbi subsets equal non-dbi subsets", {
  # skip test on cran
  skip_on_cran()

  # load libraries
  library(RSQLite)
  library(DBI)

  # set up database
  dbfile <- tempfile()
  conn <- dbConnect(RSQLite::SQLite() , dbfile)
  dbWriteTable(conn , 'eusilc' , eusilc)

  # create database-backed design (with survey design information)
  dbd_eusilc <-
    svydesign(
      ids = ~ rb030 ,
      strata = ~ db040 ,
      weights = ~ rb050 ,
      data = "eusilc",
      dbname = dbfile,
      dbtype = "SQLite"
    )

  # create a hacky database-backed svrepdesign object
  # mirroring des_eusilc_rep
  dbd_eusilc_rep <-
    svrepdesign(
      weights = ~ rb050,
      repweights = attr(des_eusilc_rep , "full_design")$repweights ,
      scale = attr(des_eusilc_rep , "full_design")$scale ,
      rscales = attr(des_eusilc_rep , "full_design")$rscales ,
      type = "bootstrap" ,
      data = "eusilc" ,
      dbtype = "SQLite" ,
      dbname = dbfile ,
      combined.weights = FALSE
    )

  # prepare for convey
  dbd_eusilc <- convey_prep(dbd_eusilc)
  dbd_eusilc_rep <- convey_prep(dbd_eusilc_rep)

  # remove groups with zero observations
  dbd_eusilc <- subset( dbd_eusilc , hsize < 7 )
  dbd_eusilc_rep <- subset( dbd_eusilc_rep , hsize < 7 )

  # calculate estimates
  sub_dbd <-
    svyfgtdec(
      ~ eqincome ,
      design = subset( dbd_eusilc , hsize == 1 ) ,
      g = 2 ,
      percent = .6 ,
      type_thresh = "relm" ,
      deff = FALSE ,
      linearized = TRUE
    )
  sby_dbd <-
    svyby(
      ~ eqincome,
      by = ~ hsize,
      design = dbd_eusilc,
      FUN = svyfgtdec ,
      g = 2 ,
      percent = .6 ,
      type_thresh = "relm" ,
      deff = FALSE ,
      covmat = FALSE # should be TRUE once we find a way to deal with full_design in svyby
    )
  sub_dbr <-
    svyfgtdec(
      ~ eqincome ,
      design = subset(dbd_eusilc_rep , hsize == 1) ,
      g = 2 ,
      percent = .6 ,
      type_thresh = "relm" ,
      deff = FALSE ,
      linearized = TRUE
    )
  sby_dbr <-
    svyby(
      ~ eqincome,
      by = ~ hsize,
      design = dbd_eusilc_rep,
      FUN = svyfgtdec ,
      g = 2 ,
      percent = .6 ,
      type_thresh = "relm" ,
      deff = FALSE ,
      covmat = TRUE
    )

  # remove table and disconnect from database
  dbRemoveTable(conn , 'eusilc')
  dbDisconnect(conn)

  # perform tests
  expect_equal(coef(sub_des) , coef(sub_dbd))
  expect_equal(coef(sub_rep) , coef(sub_dbr))
  expect_equal(SE(sub_des) , SE(sub_dbd))
  expect_equal(SE(sub_rep) , SE(sub_dbr))
  # expect_equal(deff(sub_des) , deff(sub_dbd))
  # expect_equal(deff(sub_rep) , deff(sub_dbr))
  expect_equal(vcov(sub_des) , vcov(sub_dbd))
  expect_equal(vcov(sub_rep) , vcov(sub_dbr))

  # compare database-backed subsetted objects to database-backed svyby objects
  # dbi subsets equal dbi svyby
  expect_equal(as.numeric(coef(sub_dbd)) , as.numeric(coef(sby_dbd[1, ])))
  expect_equal(as.numeric(coef(sub_dbr)) , as.numeric(coef(sby_dbr[1, ])))
  expect_equal(as.numeric(SE(sub_dbd)) , as.numeric(SE(sby_dbd[1, ])))
  expect_equal(as.numeric(SE(sub_dbr)) , as.numeric(SE(sby_dbr[1, ])))
  expect_equal(vcov(sub_dbd) , vcov(sub_des))
  expect_equal(vcov(sub_dbr) , vcov(sub_rep))

  # compare equality of linearized variables
  expect_equal(attr(sub_dbd , "linearized") , attr(sub_dbr , "linearized"))
  expect_equal(attr(sub_dbd , "linearized") , attr(sub_des , "linearized"))
  expect_equal(attr(sub_dbr , "linearized") , attr(sub_rep , "linearized"))

  # compare equality of indices
  expect_equal(attr(sub_dbd , "index") , attr(sub_dbr , "index"))
  expect_equal(attr(sub_dbd , "index") , attr(sub_des , "index"))
  expect_equal(attr(sub_dbr , "index") , attr(sub_rep , "index"))

})
