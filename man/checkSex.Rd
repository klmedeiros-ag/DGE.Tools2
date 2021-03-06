% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkSex.R
\name{checkSex}
\alias{checkSex}
\title{Function checkSex}
\usage{
checkSex(
  dgeObj,
  species,
  sexCol,
  labelCol,
  showLabels = FALSE,
  chrX = "X",
  chrY = "Y",
  baseFontSize = 14,
  orig = TRUE,
  debug = FALSE
)
}
\arguments{
\item{dgeObj}{A DGEobj (Required)}

\item{species}{One of "human", "mouse", "rat"}

\item{sexCol}{Character string name of the sex annotation column in the design table within the dgeObj (optional)}

\item{labelCol}{Character string name of the design column to use to label points with ggrepel (optional if showLabels=FALSE)}

\item{showLabels}{Set TRUE to turn on ggrepel labels (default = FALSE)}

\item{chrX}{Character string name of the X chromosome in the gene annotation within the geneData object (Default = "X")}

\item{chrY}{Character string name of the Y chromosome in the gene annotation within the geneData object (Default = "Y")}

\item{baseFontSize}{Sets the base font size for ggplot themes (Default = 14)}

\item{orig}{Set to FALSE to use your filtered DGEobj data.  Set to TRUE to use original unfiltered data (Default = TRUE)}

\item{debug}{Default=FALSE. Set to TRUE to open a debug browser when entering this function}
}
\value{
A ggplot object
}
\description{
Take a DGEobj as input and plot expression of XIST vs the highest expressed Y chr gene.
}
\details{
This uses the original unfiltered data by default.  This is because Y-linked genes are often below
the low intensity threshold in tissues other than testes.  Nevertheless, there are usually enough reads
for the plot to be interpretable.
}
\examples{

   checkSex(dgeObj, species="human")

}
\author{
John Thompson, \email{john.thompson@bms.com}
}
\keyword{DGE,}
\keyword{MDS,}
\keyword{QC}
\keyword{RNA-Seq,}
