#' At-risk-of-poverty threshold
#'
#' The standard definition is to use 60\% of the median income.
#'
#' @param formula a formula specifying the income variable
#' @param design a design object of class \code{survey.design} or class \code{svyrep.design} from the \code{survey} library.
#' @param quantiles income quantile quantiles, usually .50 (median)
#' @param percent fraction of the quantile, usually .60
#' @param na.rm Should cases with missing values be dropped?
#' @param ... arguments passed on to `survey::oldsvyquantile`
#'
#' @details you must run the \code{convey_prep} function on your survey design object immediately after creating it with the \code{svydesign} or \code{svrepdesign} function.
#'
#' @return Object of class "\code{cvystat}", which are vectors with a "\code{var}" attribute giving the variance and a "\code{statistic}" attribute giving the name of the statistic.
#'
#' @author Djalma Pessoa and Anthony Damico
#'
#' @seealso \code{\link{svyarpr}}
#'
#' @references Guillaume Osier (2009). Variance estimation for complex indicators
#' of poverty and inequality. \emph{Journal of the European Survey Research
#' Association}, Vol.3, No.3, pp. 167-195,
#' ISSN 1864-3361, URL \url{https://ojs.ub.uni-konstanz.de/srm/article/view/369}.
#'
#' Jean-Claude Deville (1999). Variance estimation for complex statistics and estimators:
#' linearization and residual techniques. Survey Methodology, 25, 193-203,
#' URL \url{https://www150.statcan.gc.ca/n1/en/catalogue/12-001-X19990024882}.
#'
#' @keywords survey
#'
#' @examples
#'
#' library(survey)
#' library(laeken)
#' data(eusilc) ; names( eusilc ) <- tolower( names( eusilc ) )
#'
#' # linearized design
#'
#' des_eusilc <- svydesign( ids = ~rb030 , strata = ~db040 ,  weights = ~rb050 , data = eusilc )
#' des_eusilc <- convey_prep( des_eusilc )
#' svyarpt( ~eqincome , design = des_eusilc )
#'
#' # replicate-weighted design
#' des_eusilc_rep <- as.svrepdesign( des_eusilc , type = "bootstrap" )
#' des_eusilc_rep <- convey_prep( des_eusilc_rep )
#' svyarpt( ~eqincome , design = des_eusilc_rep )
#'
#' \dontrun{
#'
#' # linearized design using a variable with missings
#' svyarpt( ~ py010n , design = des_eusilc )
#' svyarpt( ~ py010n , design = des_eusilc , na.rm = TRUE )
#' # replicate-weighted design using a variable with missings
#' svyarpt( ~ py010n , design = des_eusilc_rep )
#' svyarpt( ~ py010n , design = des_eusilc_rep , na.rm = TRUE )
#'
#'
#' # database-backed design
#' library(RSQLite)
#' library(DBI)
#' dbfile <- tempfile()
#' conn <- dbConnect( RSQLite::SQLite() , dbfile )
#' dbWriteTable( conn , 'eusilc' , eusilc )
#'
#' dbd_eusilc <-
#' 	svydesign(
#' 		ids = ~rb030 ,
#' 		strata = ~db040 ,
#' 		weights = ~rb050 ,
#' 		data="eusilc",
#' 		dbname=dbfile,
#' 		dbtype="SQLite"
#' 	)
#'
#' dbd_eusilc <- convey_prep( dbd_eusilc )
#'
#' svyarpt( ~ eqincome , design = dbd_eusilc )
#'
#' dbRemoveTable( conn , 'eusilc' )
#'
#' dbDisconnect( conn , shutdown = TRUE )
#'
#' }
#'
#' @export
svyarpt <-
  function(formula, design, ...) {
    if (length(attr(terms.formula(formula) , "term.labels")) > 1)
      stop(
        "convey package functions currently only support one variable in the `formula=` argument"
      )

    UseMethod("svyarpt", design)

  }

#' @rdname svyarpt
#' @export
svyarpt.survey.design <-
  function(formula,
           design,
           quantiles = 0.5,
           percent = 0.6,
           na.rm = FALSE,
           ...) {
    if (is.null(attr(design, "full_design")))
      stop(
        "you must run the ?convey_prep function on your linearized survey design object immediately after creating it with the svydesign() function."
      )

    # if the class of the full_design attribute is just a TRUE, then the design is
    # already the full design.  otherwise, pull the full_design from that attribute.
    if ("logical" %in% class(attr(design, "full_design")))
      full_design <-
        design
    else
      full_design <- attr(design, "full_design")
    incvar <-
      model.frame(formula, design$variables, na.action = na.pass)[[1]]

    if (na.rm) {
      nas <- is.na(incvar)
      design$prob <- ifelse( nas , Inf , design$prob )
      incvar[nas] <- 0
    }
    ind <- rownames( design$variables )[ is.finite( design$prob ) ]

    incvec <-
      model.frame(formula, full_design$variables, na.action = na.pass)[[1]]

    if (na.rm) {
      nas <- is.na(incvec)
      full_design$prob <- ifelse( nas , Inf , full_design$prob )
      incvec[ nas ] <- 0
    }
    ncom <- rownames( full_design$variables )

    w <- 1 / design$prob
    wf <- 1 / full_design$prob
    htot <- h_fun( incvar, w )
    q_alpha <-
      survey::oldsvyquantile(
        x = formula,
        design = design,
        quantiles = quantiles,
        method = "constant",
        na.rm = na.rm,
        ...
      )
    q_alpha <- as.vector(q_alpha)
    rval <- percent * q_alpha
    Fprime <-
      densfun(
        formula = formula,
        design = design,
        q_alpha,
        h = htot,
        FUN = "F",
        na.rm = na.rm
      )
    N <- sum( w )
    ID <- 1 * ( ncom %in% ind )
    linquant <- -(1 / (N * Fprime)) * ID * ((incvec <= q_alpha) - quantiles)
    lin <- percent * linquant

    varest <-
      survey::svyrecvar(
        lin / full_design$prob,
        full_design$cluster,
        full_design$strata,
        full_design$fpc,
        postStrata = full_design$postStrata
      )

    colnames(varest) <-
      rownames(varest) <-
      names(rval) <-
      strsplit(as.character(formula)[[2]] , ' \\+ ')[[1]]
    class(rval) <- c("cvystat" , "svystat")
    attr(rval, "var") <- varest
    attr(rval, "statistic") <- "arpt"
    attr(rval, "lin") <- lin
    rval
  }

#' @rdname svyarpt
#' @export
svyarpt.svyrep.design <-
  function(formula,
           design,
           quantiles = 0.5,
           percent = 0.6,
           na.rm = FALSE,
           ...) {
    if (is.null(attr(design, "full_design")))
      stop(
        "you must run the ?convey_prep function on your replicate-weighted survey design object immediately after creating it with the svrepdesign() function."
      )


    # if the class of the full_design attribute is just a TRUE, then the design is
    # already the full design.  otherwise, pull the full_design from that attribute.
    if ("logical" %in% class(attr(design, "full_design")))
      full_design <-
        design
    else
      full_design <- attr(design, "full_design")


    df <- model.frame(design)
    incvar <-
      model.frame(formula, design$variables, na.action = na.pass)[[1]]
    if (na.rm) {
      nas <- is.na(incvar)
      design <- design[!nas, ]
      df <- model.frame(design)
      incvar <- incvar[!nas]
    }

    w <- weights(design, "sampling")
    quant_val <- computeQuantiles(incvar, w, p = quantiles)
    quant_val <- as.vector(quant_val)
    rval <- percent * quant_val
    ww <- weights(design, "analysis")
    qq <-
      apply(ww, 2, function(wi)
        0.6 * computeQuantiles(incvar, wi, p = quantiles))
    if (anyNA(qq))
      varest <- NA
    else
      varest <-
      survey::svrVar(qq,
                     design$scale,
                     design$rscales,
                     mse = design$mse,
                     coef = rval)

    varest <- as.matrix(varest)

    colnames(varest) <-
      rownames(varest) <-
      names(rval) <-
      strsplit(as.character(formula)[[2]] , ' \\+ ')[[1]]
    class(rval) <- c("cvystat" , "svrepstat")
    attr(rval, "var") <- varest
    attr(rval, "statistic") <- "arpt"
    rval
  }

#' @rdname svyarpt
#' @export
svyarpt.DBIsvydesign <-
  function (formula, design, ...)
  {
    if (!("logical" %in% class(attr(design, "full_design")))) {
      full_design <- attr(design , "full_design")

      full_design$variables <-
        getvars(
          formula,
          attr(design , "full_design")$db$connection,
          attr(design , "full_design")$db$tablename,
          updates = attr(design , "full_design")$updates,
          subset = attr(design , "full_design")$subset
        )

      attr(design , "full_design") <- full_design

      rm(full_design)

    }

    design$variables <-
      getvars(
        formula,
        design$db$connection,
        design$db$tablename,
        updates = design$updates,
        subset = design$subset
      )

    NextMethod("svyarpt", design)
  }
