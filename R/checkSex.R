### Function checkSex ###
#' Function checkSex
#'
#' Take a DGEobj as input and plot expression of XIST vs the highest expressed Y chr gene.
#'
#' @author John Thompson, \email{john.thompson@@bms.com}
#' @keywords MDS, RNA-Seq, DGE, QC
#'
#' @param dgeObj A DGEobj (Required)
#' @param species One of "human", "mouse", "rat"
#' @param sexCol Name of the sex annotation column in the design table within the dgeObj
#' @param labelCol Name of the design column to use to label points
#' @param showLables Set TRUE to label points with labelcol (default = FALSE)
#' @param chrX Name of the X chromosome in the gene annotation within the geneData object (Default = "X")
#' @param chrY Name of the Y chromosome in the gene annotation within the geneData object (Default = "Y")
#' @param baseFontSize Sets the base font size for ggplot themes (Default = 14)
#'
#' @return A ggplot object
#'
#' @examples
#'
#' @import ggplot2 magrittr edgeR assertthat ggrepel ggiraph
#'
#' @export
checkSex <- function(dgeObj, species, sexCol, labelCol, showLabels=FALSE, chrX = "X", chrY = "Y", baseFontSize=14) {

  #convert this to a function in DGE.Tools2
  #input dgeObj, optionally specify x and y genes
  ##if genes not specified, pick highest expressed of each x and y gene
  assert_that(tolower(species) %in% c("human", "mouse", "rat"),
              !missing(species),
              !missing(sexCol),
              !missing(labelCol))

  if (tolower(species) == "rat") { #no XIST in Rat
    x <- .getTopExpressedGene(dgeObj, chr=chrX, orig=TRUE)
  } else {
    x <- switch(tolower(species),
                human = list(gene="ENSG00000229807", genename="XIST"),
                mouse = list(gene="ENSMUSG00000086503", genename="Xist")
    )
  }

  # x <- .getTopExpressedGene(dgeObj, "X")
  y <- .getTopExpressedGene(dgeObj, chr=chrY, orig=TRUE)

  #get data for the two x and y genes
  log2CPM <- convertCounts(getItem(dgeObj, "counts_orig"), unit="cpm", log=TRUE, normalize="tmm")
  idx <- rownames(log2CPM) %in% c(x$gene, y$gene)
  plotdat <- t(log2CPM[idx,]) %>%
    as.data.frame %>%
    rownames_to_column(var="rowname")

  #add sample identifier data
  dtemp <- getItem(dgeObj, "design_orig") %>%
    rownames_to_column(var="rowname") %>%
    select(rowname, labelCol=labelCol, sexCol=sexCol)
  plotdat2 <- left_join(plotdat, dtemp)

  colnames(plotdat2) <- c("SampID", x$genename, y$genename, labelCol, sexCol)

  sexPlot <- ggplot(plotdat2, aes_string(x=x$genename, y=y$genename, label=labelCol, color=sexCol)) +
    geom_point(size=4, shape=21) +
    xlab(paste("X (", x$genename, ")", sep="")) +
    ylab(paste("Y (", y$genename, ")", sep="")) +
    ggtitle("Sex Determination Plot") +
    theme_grey()
  if (showLabels == TRUE)
    sexPlot <-sexPlot + geom_label_repel (label.size=0.125)

  return(sexPlot)
}


#non-exported functions
#
#
#support function for Sex analysis
.getChrDat <- function(dgeObj, chr, orig=FALSE){
  # chr can be one or more chromosome names
  if (orig == TRUE) {
    geneData <- getItem(dgeObj, "geneData_orig")
    log2CPM <- convertCounts(getItem(dgeObj, "counts_orig"), unit="cpm", log=TRUE, normalize="tmm")
  } else {
    geneData <- getItem(dgeObj, "geneData")
    log2CPM <- convertCounts(getItem(dgeObj, "counts"), unit="cpm", log=TRUE, normalize="tmm")
  }

  #filter to specified chr
  if (!is.null(chr))
    geneData %<>%
    as.data.frame() %>%
    rownames_to_column(var="geneid") %>%
    filter(toupper(Chromosome) %in% toupper(chr)) %>%
    column_to_rownames(var="geneid")

  log2CPM_mat <- log2CPM[rownames(log2CPM) %in% rownames(geneData),]

  return(log2CPM_mat)
}


.getTopExpressedGene <- function (dgeObj, chr, orig=FALSE){
  #get top mean expressed gene from given chromosome

  if (orig == TRUE) {
    geneData <- getItem(dgeObj, "geneData_orig")
  } else {
    geneData <- getItem(dgeObj, "geneData")
  }

  #filter geneData to selected chr
  if (!is.null(chr))
    log2CPM_mat <- .getChrDat(dgeObj, chr=chr, orig=orig)

  meanLogCPM <- rowMeans(log2CPM_mat)

  #get the top expressed gene data
  #Calc mean and sort on mean descending
  log2CPM  <- log2CPM_mat %>%
    as.data.frame() %>%
    rownames_to_column(var="geneid") %>%
    mutate(meanLogCPM = meanLogCPM) %>%
    arrange(desc(meanLogCPM)) %>%
    mutate(meanLogCPM = NULL) %>%
    column_to_rownames(var="geneid")
  gene <- rownames(log2CPM)[1]
  genename <- geneData$GeneName[rownames(geneData) == gene]
  # dat <- log2CPM %>%
  #   rownames_to_column(var="geneid") %>%
  #   filter(geneid == gene) %>%
  #   column_to_rownames(var="geneid") %>%
  #   as.numeric

  return(list(gene=gene, genename=genename))
}