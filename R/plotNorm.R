### Function plotNorm ###
#' Function plotNorm
#'
#' Takes a DGEobj (containing counts) or a counts matrix as input. Returns a ggplot object containing
#' a faceted plot of log2CPM before/after normalization. Either a box plot or density plot
#' type can be chosen.
#'
#' Normalization is performed by edgeR::calcNormFactors. Note TMM is specifically tailored to count-based
#' data.  Thus this function is only appropriate for count-based data.
#'
#' @author John Thompson, \email{john.thompson@@bms.com}
#' @keywords RNA-Seq, DGEobj
#'
#' @param dat  A DGEobj or counts matrix
#' @param plotType  One of "box" or "density" (default="box")
#' @param normalize Default = "TMM" and invokes TMM normalization. Other allowed
#'   values are: "RLE","upperquartile", "none". Invokes edgeR::calcNormFactors for
#'   normalization.
#' @param baseFontSize Passed on as base font size in ggplot theme. (default=12)
#'
#' @return A  facetted ggplot plot showing before/after normalization
#'
#' @examples
#'    MyggPlot <- plotNorm(MyDgeObj, plotType="box")
#'    MyggPlot <- plotNorm(counts, plotType="density")
#'
#' @import magrittr ggplot2
#' @importFrom stringr str_c
#' @importFrom tidyr gather
#' @importFrom tibble rownames_to_column
#' @importFrom DGEobj getItem
#' @importFrom assertthat assert_that
#'
#' @export
# For sourcing during dev:
# library(tidyverse)
# library(magrittr)
# library(assertthat)
# library(DGEobj)
# library(DGE.Tools2)
# library(stringr)
plotNorm <- function(dat, plotType="box", normalize="tmm", baseFont=12){

  assertthat::assert_that(any(c("matrix", "DGEobj") %in% class(dat)),
                          tolower(plotType) %in% c("box", "density"),
                          tolower(normalize) %in% c("tmm", "rle", "upperquartile", "none")
  )

  if (class(dat)[[1]] == "matrix") {
    counts <- dat
  } else {
    counts <- DGEobj::getItem(dat, "counts")
  }

  log2cpm <- convertCounts(counts, unit="cpm", log=TRUE, normalize="none")
  log2CPM_tmm <- convertCounts(counts, unit="cpm", log=TRUE, normalize=normalize)

  #convert to tall/shinny for facetted plotting
  tall <- log2cpm %>%
    as.data.frame %>%
    tibble::rownames_to_column(var="GeneID") %>%
    tidyr::gather (SampleID, Log2CPM, -GeneID)
  tall$Normalization = "none"

  tall_tmm <- log2CPM_tmm %>%
    as.data.frame %>%
    tibble::rownames_to_column(var="GeneID") %>%
    tidyr::gather (SampleID, Log2CPM, -GeneID)
  tall_tmm$Normalization = toUpper(normalize)

  tall %<>% rbind(tall_tmm)

  if (tolower(plotType) == "density"){
    #need to facet the plots by Normalization
    #DensityPlot
    resultPlot <- ggplot (tall, aes(x=Log2CPM, color=SampleID)) +
      geom_density() +
      facet_grid (~ Normalization) +
      ggtitle(stringr::str_c("Log2CPM before/after", normalize, "normalization", sep=" "))  +
      theme_gray() +
      NoLegend()
  }

  if (tolower(plotType == "box")){
    #Box  plot
    resultPlot <- ggplot(tall, aes(x = SampleID, y=Log2CPM, color=SampleID)) +
      geom_boxplot(alpha=0.5) +
      # geom_violin(alpha=0.5) +
      facet_grid (~ Normalization) +
      ggtitle(stringr::str_c("Log2CPM before/after", normalize, "normalization", sep=" "))  +
      theme_gray() +
      NoXlab() +
      NoLegend()
  }

  return(resultPlot)
}

