# -----------------------------------------------------------------------------
# Generate class2dom ----------------------------------------------------------
# -----------------------------------------------------------------------------

class2dom <- read.table("data/class2domain.csv", header=T, sep=",", row.names = 1)

# -----------------------------------------------------------------------------
# Generate OMs modes ----------------------------------------------------------
# -----------------------------------------------------------------------------

library("randomForest")

# load dataset
TBL_DOM_TRAIN <- read.table("data/metagenomes_dom_annot_wide_omrgc.tsv",
                            header=T, sep="\t", row.names = 1)

TBL_CLASS_TRAIN <- read.table("data/ref_genomes_class_cov_wide_omrgc.tsv",
                              header=T, sep="\t", row.names = 1)


# join and convert to relative counts
data_train <- dplyr::inner_join(x = tibble::rownames_to_column( TBL_DOM_TRAIN / rowSums( TBL_DOM_TRAIN )  ),
                                y = tibble::rownames_to_column( TBL_CLASS_TRAIN / rowSums( TBL_CLASS_TRAIN )),
                                by = "rowname" )

#bgc_classes <- colnames(TBL_CLASS_TRAIN)

# based on the cross validation performance we selected the following classes
bgc_classes <- c("bacteriocin","butyrolactone","cyanobactin","ectoine","furan",
                  "hserlactone","indole","lantipeptide","microviridin","nrps",
                  "oligosaccharide","otherks","phenazine","phosphonate",
                  "sactipeptide","siderophore","t1pks","t2pks","t3pks","terpene",
                  "thiopeptide","transatpks")

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
# Generate models general -----------------------------------------------------
# -----------------------------------------------------------------------------

library("randomForest")

# load dataset
TBL_DOM_TRAIN <- read.table("data/metagenomes_dom_annot_wide_general.tsv",
                            header=T, sep="\t", row.names = 1)

TBL_CLASS_TRAIN <- read.table("data/ref_genomes_class_cov_wide_general.tsv",
                              header=T, sep="\t", row.names = 1)


# join and convert to relative counts
data_train <- dplyr::inner_join(x = tibble::rownames_to_column( TBL_DOM_TRAIN / rowSums( TBL_DOM_TRAIN )  ),
                                y = tibble::rownames_to_column( TBL_CLASS_TRAIN / rowSums( TBL_CLASS_TRAIN )),
                                by = "rowname" )

#bgc_classes <- colnames(TBL_CLASS_TRAIN)

# based on the cross validation performance we selected the following classes
bgc_classes <- c("butyrolactone","cyanobactin","ectoine", "hserlactone",
                 "indole","lantipeptide","microviridin","nrps","otherks",
                 "phenazine","phosphonate","siderophore","t1pks","t2pks",
                 "t3pks","terpene","transatpks")


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

OMs_class <- read.table("data/ref_genomes_class_cov_wide_omrgc.tsv",
                        header=T, sep=",", row.names = 1)

OMs_domain <- read.table("data/ref_genomes_class_cov_wide_omrgc.tsv",
                          header=T, sep=",", row.names = 1)

TGs_class <- read.table("data/150_class_abund_simulated_TGs.csv",
                        header=T, sep=",", row.names = 1)

TGs_domain <- read.table("data/150_domain_abund_simulated_TGs.csv",
                         header=T, sep=",", row.names = 1)

GENERAL_class <- read.table("data/ref_genomes_class_cov_wide_general.tsv",
                            header=T, sep=",", row.names = 1)

GENERAL_domain <- read.table("data/ref_genomes_class_cov_wide_general.tsv",
                             header=T, sep=",", row.names = 1)

# -----------------------------------------------------------------------------
# Save data -------------------------------------------------------------------
# -----------------------------------------------------------------------------

devtools::use_data(OMs_class, OMs_domain,
                   TGs_class, TGs_domain,
                   GENERAL_class, GENERAL_domain,
                   internal = FALSE, overwrite = TRUE)


