% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/svyzenga.R
\name{svyzenga}
\alias{svyzenga}
\alias{svyzenga.survey.design}
\alias{svyzenga.svyrep.design}
\alias{svyzenga.DBIsvydesign}
\title{Zenga index}
\usage{
svyzenga(formula, design, ...)

\method{svyzenga}{survey.design}(
  formula,
  design,
  na.rm = FALSE,
  deff = FALSE,
  linearized = FALSE,
  influence = FALSE,
  ...
)

\method{svyzenga}{svyrep.design}(
  formula,
  design,
  na.rm = FALSE,
  deff = FALSE,
  linearized = FALSE,
  return.replicates = FALSE,
  ...
)

\method{svyzenga}{DBIsvydesign}(formula, design, ...)
}
\arguments{
\item{formula}{a formula specifying the income variable}

\item{design}{a design object of class \code{survey.design} or class \code{svyrep.design} from the \code{survey} library.}

\item{...}{future expansion}

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
Estimate the Zenga index, a measure of inequality
}
\details{
you must run the \code{convey_prep} function on your survey design object immediately after creating it with the \code{svydesign} or \code{svrepdesign} function.
}
\examples{
library(survey)
library(laeken)
data(eusilc) ; names( eusilc ) <- tolower( names( eusilc ) )

# linearized design
des_eusilc <- svydesign( ids = ~rb030 , strata = ~db040 ,  weights = ~rb050 , data = eusilc )
des_eusilc <- convey_prep(des_eusilc)

svyzenga( ~eqincome , design = des_eusilc )

# replicate-weighted design
des_eusilc_rep <- as.svrepdesign( des_eusilc , type = "bootstrap" )
des_eusilc_rep <- convey_prep(des_eusilc_rep)

svyzenga( ~eqincome , design = des_eusilc_rep )

\dontrun{

# linearized design using a variable with missings
svyzenga( ~ py010n , design = des_eusilc )
svyzenga( ~ py010n , design = des_eusilc , na.rm = TRUE )
# replicate-weighted design using a variable with missings
svyzenga( ~ py010n , design = des_eusilc_rep )
svyzenga( ~ py010n , design = des_eusilc_rep , na.rm = TRUE )

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

svyzenga( ~ eqincome , design = dbd_eusilc )

dbRemoveTable( conn , 'eusilc' )

dbDisconnect( conn , shutdown = TRUE )

}

}
\references{
Lucio Barabesi, Giancarlo Diana and Pier Francesco Perri (2016). Linearization of inequality indices in the design-based framework. Statistics, 50(5), 1161-1172.
DOI \doi{10.1080/02331888.2015.1135924}.

Matti Langel and Yves Tille (2012). Inference by linearization for Zenga's new inequality index: a comparison with the Gini index.
Metrika, 75, 1093-1110. DOI \doi{10.1007/s00184-011-0369-1}.

Matti Langel (2012). Measuring inequality in finite population sampling.
PhD thesis: Universite de Neuchatel,
URL \url{https://doc.rero.ch/record/29204/files/00002252.pdf}.
}
\seealso{
\code{\link{svygini}}
}
\author{
Djalma Pessoa, Guilherme Jacob, and Anthony Damico
}
\keyword{survey}
