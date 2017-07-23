# -----------------------------------------------------------------------------
# Generate class2dom ----------------------------------------------------------
# -----------------------------------------------------------------------------

class2dom <- read.table("data/class2domain.csv", header=T, sep=",", row.names = 1)

# -----------------------------------------------------------------------------
# Generate models -------------------------------------------------------------
# -----------------------------------------------------------------------------

library("randomForest")

# load dataset
TBL_DOM_TRAIN <- read.table("data/150_domain_abund_simulated_OMs.csv",
                            header=T, sep=",", row.names = 1)

TBL_CLASS_TRAIN <- read.table("data/150_class_abund_simulated_OMs.csv",
                              header=T, sep=",", row.names = 1)


# join and convert to relative counts
data_train <- dplyr::inner_join(x = tibble::rownames_to_column( TBL_DOM_TRAIN / rowSums( TBL_DOM_TRAIN )  ),
                        y = tibble::rownames_to_column( TBL_CLASS_TRAIN / rowSums( TBL_CLASS_TRAIN )),
                        by = "rowname" )

bgc_classes <- colnames(TBL_CLASS_TRAIN)
models_list <- list()

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

    models_list[[b]] <- class_model_train(x = x_train,
                                          y = y_train,
                                          regression_method = "lm",
                                          binary_method = "rf")

    models_list[[b]]$doms <- doms

}

# -----------------------------------------------------------------------------
# Save data -------------------------------------------------------------------
# -----------------------------------------------------------------------------

devtools::use_data(class2dom, models_list, internal = TRUE, overwrite = TRUE)

# -----------------------------------------------------------------------------
# External data: simulated datasets -------------------------------------------
# -----------------------------------------------------------------------------

OMs_class <- read.table("data/150_class_abund_simulated_OMs.csv",
                        header=T, sep=",", row.names = 1)

OMs_domain <- read.table("data/150_domain_abund_simulated_OMs.csv",
                          header=T, sep=",", row.names = 1)

TGs_class <- read.table("data/150_class_abund_simulated_TGs.csv",
                        header=T, sep=",", row.names = 1)

TGs_domain <- read.table("data/150_domain_abund_simulated_TGs.csv",
                         header=T, sep=",", row.names = 1)

# -----------------------------------------------------------------------------
# Save data -------------------------------------------------------------------
# -----------------------------------------------------------------------------

devtools::use_data(OMs_class, OMs_domain, TGs_class, TGs_domain,
                   internal = FALSE, overwrite = F)


