% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_funs.R
\name{icdf}
\alias{icdf}
\title{Linearization of the cumulative distribution function (cdf) of a variable}
\usage{
icdf(formula, design, x, na.rm = FALSE, ...)
}
\arguments{
\item{formula}{a formula specifying the income variable}

\item{design}{a design object of class \code{survey.design} or class \code{svyrep.design} from the \code{survey} library.}

\item{x}{the point where the cdf is calculated}

\item{na.rm}{Should cases with missing values be dropped?}

\item{...}{future expansion}
}
\value{
Object of class "\code{cvystat}", which are vectors with a "\code{var}" attribute giving the variance and a "\code{statistic}" attribute giving the name of the statistic.
}
\description{
Computes the linearized variable of the cdf function in a point.
}
\examples{
library(laeken)
data(eusilc) ; names( eusilc ) <- tolower( names( eusilc ) )
library(survey)
des_eusilc <- svydesign(ids = ~rb030, strata =~db040,  weights = ~rb050, data = eusilc)
des_eusilc <- convey_prep( des_eusilc )
icdf(~eqincome, design=des_eusilc, 10000 )
# linearized design using a variable with missings
icdf( ~ py010n , design = des_eusilc, 10000 )
icdf( ~ py010n , design = des_eusilc , 10000, na.rm = TRUE )
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
Djalma Pessoa and Anthony Damico
}
\keyword{survey}
