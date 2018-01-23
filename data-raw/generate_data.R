# -----------------------------------------------------------------------------
# Generate class2dom ----------------------------------------------------------
# -----------------------------------------------------------------------------

class2dom <- read.table("data/class2domain.csv", header=T, sep=",", row.names = 1)

# -----------------------------------------------------------------------------
# Generate OMs models ----------------------------------------------------------
# -----------------------------------------------------------------------------

library("bgcpred")
URL <- "https://raw.githubusercontent.com/wiki/pereiramemo/ufBGCtoolbox/files/"
OMs_DOM_URL <- paste(URL,"OMs_metagenomes_dom_annot_wide.tsv",sep = "")
OMs_CLASS_URL <- paste(URL,"OMs_ref_genomes_class_cov_wide.tsv",sep = "")

# load dataset
TBL_DOM_TRAIN <- read.table(OMs_DOM_URL, header = T, sep = "\t", row.names = 1)
TBL_CLASS_TRAIN <- read.table(OMs_CLASS_URL, header = T, sep = "\t", row.names = 1)

# join and convert to relative counts
data_train <- dplyr::inner_join(x = tibble::rownames_to_column( TBL_DOM_TRAIN / rowSums( TBL_DOM_TRAIN )  ),
                                y = tibble::rownames_to_column( TBL_CLASS_TRAIN / rowSums( TBL_CLASS_TRAIN )),
                                by = "rowname" )

bgc_classes <- colnames(TBL_CLASS_TRAIN)


models_list_oms <- list()

for ( b in bgc_classes ) {

    doms <- get_domains(b)
    di <- doms %in% colnames(TBL_DOM_TRAIN)
    doms <- doms[di]

    print(b)
    if ( length(doms) == 0 ) {
      next
    }

    x_train <- data_train[ ,doms, drop = F]
    y_train <- data_train[ ,b, drop = T]

    models_list_oms[[b]] <- class_model_train(x = x_train,
                                          y = y_train,
                                          regression_method = "lm",
                                          binary_method = "rf")

    models_list_oms[[b]]$doms <- doms

}

# -----------------------------------------------------------------------------
# Generate general models -----------------------------------------------------
# -----------------------------------------------------------------------------

# load dataset

General_DOM_URL <- paste(URL,"General_metagenomes_dom_annot_wide.tsv",sep = "")
General_CLASS_URL <- paste(URL,"General_ref_genomes_class_cov_wide.tsv",sep = "")

TBL_DOM_TRAIN <- read.table(General_DOM_URL, header = T, sep = "\t", row.names = 1)
TBL_CLASS_TRAIN <- read.table(General_CLASS_URL, header=T, sep="\t", row.names = 1)

# join and convert to relative counts
data_train <- dplyr::inner_join(x = tibble::rownames_to_column( TBL_DOM_TRAIN / rowSums( TBL_DOM_TRAIN )  ),
                                y = tibble::rownames_to_column( TBL_CLASS_TRAIN / rowSums( TBL_CLASS_TRAIN )),
                                by = "rowname" )

#bgc_classes <- colnames(TBL_CLASS_TRAIN)

models_list_general <- list()

for ( b in bgc_classes ) {

  doms <- get_domains(b)
  di <- doms %in% colnames(TBL_DOM_TRAIN)
  doms <- doms[di]

  print(b)
  if ( length(doms) == 0 ) {
    next
  }

  x_train <- data_train[ ,doms, drop = F]
  y_train <- data_train[ ,b, drop = T]

  models_list_general[[b]] <- class_model_train(x = x_train,
                                                y = y_train,
                                                regression_method = "lm",
                                                binary_method = "rf")

  models_list_general[[b]]$doms <- doms

}

# -----------------------------------------------------------------------------
# Save data -------------------------------------------------------------------
# -----------------------------------------------------------------------------

devtools::use_data(class2dom, models_list_general, models_list_oms,
                   internal = TRUE, overwrite = TRUE)

# -----------------------------------------------------------------------------
# External data: simulated datasets -------------------------------------------
# -----------------------------------------------------------------------------

OMs_domain <- read.table(OMs_DOM_URL, header=T, sep="\t", row.names = 1)
OMs_class <- read.table(OMs_CLASS_URL, header=T, sep="\t", row.names = 1)


TGs_DOM_URL <- paste(URL,"TGs_metagenomes_dom_annot_wide.tsv",sep = "")
TGs_CLASS_URL <- paste(URL,"TGs_ref_genomes_class_cov_wide.tsv",sep = "")
TGs_domain <- read.table(TGs_DOM_URL, header = T, sep = "\t", row.names = 1)
TGs_class <- read.table(TGs_CLASS_URL, header = T, sep = "\t", row.names = 1)

GENERAL_domain <- read.table(General_DOM_URL, header=T, sep = "\t", row.names = 1)
GENERAL_class <- read.table(General_CLASS_URL, header=T, sep="\t", row.names = 1)

# -----------------------------------------------------------------------------
# Save data -------------------------------------------------------------------
# -----------------------------------------------------------------------------

devtools::use_data(OMs_class, OMs_domain,
                   TGs_class, TGs_domain,
                   GENERAL_class, GENERAL_domain,
                   internal = FALSE, overwrite = TRUE)


