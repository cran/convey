% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/svyisq.R
\name{svyisq}
\alias{svyisq}
\alias{svyisq.survey.design}
\alias{svyisq.svyrep.design}
\alias{svyisq.DBIsvydesign}
\title{Linearization of the total below a quantile}
\usage{
svyisq(formula, design, ...)

\method{svyisq}{survey.design}(
  formula,
  design,
  alpha,
  quantile = FALSE,
  upper = FALSE,
  na.rm = FALSE,
  deff = FALSE,
  linearized = FALSE,
  influence = FALSE,
  ...
)

\method{svyisq}{svyrep.design}(
  formula,
  design,
  alpha,
  quantile = FALSE,
  upper = FALSE,
  na.rm = FALSE,
  deff = FALSE,
  linearized = FALSE,
  return.replicates = FALSE,
  ...
)

\method{svyisq}{DBIsvydesign}(formula, design, ...)
}
\arguments{
\item{formula}{a formula specifying the income variable}

\item{design}{a design object of class \code{survey.design} or class \code{svyrep.design} from the \code{survey} library.}

\item{...}{arguments passed on to `survey::oldsvyquantile`}

\item{alpha}{the order of the quantile}

\item{quantile}{return the upper bound of the lower tail}

\item{upper}{return the total in the total in the upper tail. Defaults to \code{FALSE}.}

\item{na.rm}{Should cases with missing values be dropped?}

\item{deff}{Return the design effect (see \code{survey::svymean})}

\item{linearized}{Should a matrix of linearized variables be returned}

\item{influence}{Should a matrix of (weighted) influence functions be returned? (for compatibility with \code{\link[survey]{svyby}})}

\item{return.replicates}{Return the replicate estimates?}
}
\value{
Object of class "\code{cvystat}", which are vectors with a "\code{var}" attribute giving the variance and a "\code{statistic}" attribute giving the name of the statistic.
}
\description{
Computes the linearized variable of the total in the lower tail of
the distribution of a variable.
}
\details{
you must run the \code{convey_prep} function on your survey design object immediately after creating it with the \code{svydesign} or \code{svrepdesign} function.
}
\examples{
library(laeken)
data(eusilc) ; names( eusilc ) <- tolower( names( eusilc ) )
library(survey)
des_eusilc <- svydesign(ids = ~rb030, strata =~db040,  weights = ~rb050, data = eusilc)
des_eusilc <- convey_prep(des_eusilc)
svyisq(~eqincome, design=des_eusilc,.20 , quantile = TRUE)

# replicate-weighted design
des_eusilc_rep <- as.svrepdesign( des_eusilc , type = "bootstrap" )
des_eusilc_rep <- convey_prep(des_eusilc_rep)

svyisq( ~eqincome , design = des_eusilc_rep, .20 , quantile = TRUE )

\dontrun{

# linearized design using a variable with missings
svyisq( ~ py010n , design = des_eusilc, .20 )
svyisq( ~ py010n , design = des_eusilc , .20, na.rm = TRUE )
# replicate-weighted design using a variable with missings
svyisq( ~ py010n , design = des_eusilc_rep, .20 )
svyisq( ~ py010n , design = des_eusilc_rep , .20,  na.rm = TRUE )

# database-backed design
library(RSQLite)
library(DBI)
dbfile <- tempfile()
conn <- dbConnect( RSQLite::SQLite() , dbfile )
dbWriteTable( conn , 'eusilc' , eusilc )

dbd_eusilc <-
	svydesign(
		ids = ~rb030 ,
		strata = ~db040 ,
		weights = ~rb050 ,
		data="eusilc",
		dbname=dbfile,
		dbtype="SQLite"
	)

dbd_eusilc <- convey_prep( dbd_eusilc )

svyisq( ~ eqincome , design = dbd_eusilc, .20 )

dbRemoveTable( conn , 'eusilc' )

dbDisconnect( conn , shutdown = TRUE )

}

}
\references{
Guillaume Osier (2009). Variance estimation for complex indicators
of poverty and inequality. \emph{Journal of the European Survey Research
Association}, Vol.3, No.3, pp. 167-195,
ISSN 1864-3361, URL \url{https://ojs.ub.uni-konstanz.de/srm/article/view/369}.

Jean-Claude Deville (1999). Variance estimation for complex statistics and estimators:
linearization and residual techniques. Survey Methodology, 25, 193-203,
URL \url{https://www150.statcan.gc.ca/n1/en/catalogue/12-001-X19990024882}.
}
\seealso{
\code{\link{svyarpr}}
}
\author{
Djalma Pessoa, Guilherme Jacob, and Anthony Damico
}
\keyword{survey}
