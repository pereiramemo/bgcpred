#------------------------------------------------------------------------------
# OMs datasets
#------------------------------------------------------------------------------

#' OMs class dataset
#'
#' OMs dataset contains the BGC class annotation of the synthetic marine
#' metagenomes created based on complete (or nearly complete) genome sequences
#' of the Ocean Microbial Reference Gene Catalogue (OM-RGC)
#' (Sunagawa et al., 2015) and the Metagenome Assembled Genomes of TARA Oceans
#' (MAGs) (Delmont, et al., 2017).
#'
#' @format A data frame 150 rows (metagenomes) and 30 variables (BGC domains):
#' \describe{
#'   \item{bgc_domain}{raw abundance}
#'   ...
#' }
"OMs_class"

#' OMs domain dataset
#'
#' OMs dataset contains the BGC domain annotation of the synthetic marine
#' metagenomes created based on complete (or nearly complete) genome sequences
#' of the Ocean Microbial Reference Gene Catalogue (OM-RGC)
#' (Sunagawa et al., 2015) and the Metagenome Assembled Genomes of TARA Oceans
#' (MAGs) (Delmont, et al., 2017).
#'
#' @format A data frame 150 rows (metagenomes) and 82 variables (BGC domains):
#' \describe{
#'   \item{bgc_domain}{raw abundance}
#'   ...
#' }
"OMs_domain"

#------------------------------------------------------------------------------
# TGs datasets
#------------------------------------------------------------------------------

#' TGs class dataset
#'
#' TGs dataset contains the BGC class annotation of the synthetic marine
#' metagenomes created based on representative complete genome
#' sequences of the genus found in the OTU taxonomic classification of the TARA
#' Oceans Project (Karsenti et al., 2011).
#'
#' @format A data frame 150 rows (metagenomes) and 31 variables (BGC classes):
#' \describe{
#'   \item{bgc_class}{raw abundance}
#'   ...
#' }
"TGs_class"

#' TGs domain dataset
#'
#' TGs dataset contains the BGC domain annotation of the synthetic marine
#' metagenomes created based on representative complete genome
#' sequences of the genus found in the OTU taxonomic classification of the TARA
#' Oceans Project (Karsenti et al., 2011).
#'
#' @format A data frame 150 rows (metagenomes) and 87 variables (BGC domains):
#' \describe{
#'   \item{bgc_domain}{raw abundance}
#'   ...
#' }
"TGs_domain"


