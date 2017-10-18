# -----------------------------------------------------------------------------
# get domains -----------------------------------------------------------------
# -----------------------------------------------------------------------------

#' Map BGC class to domains
#'
#' @param bgc_class a character. Name of the target BGC class.
#' @param class2dom a matrix or data defining the mapping between classes and domains
#' @return A character vector with domain names.
#' @examples
#' get_domains("t1pks")
#' get_domains("nrps")

get_domains <- function(bgc_class) {

  X_DOMS <- class2dom  %>%
            filter(class %in% bgc_class ) %>%
            select(domain) %>%
            .[,1] %>%
            as.character()
  return(X_DOMS)

}

# -----------------------------------------------------------------------------
# bgc class rc modeling -------------------------------------------------------
# -----------------------------------------------------------------------------

#' Generate the BGC class models.
#'
#' @param y a numeric vector. This is the response variables
#' (i.e. class abundances).
#' @param x a matrix of data frame. These are the predictor variables
#' (i.e. domain abundances).
#' @param binary_method method used in the binary classification. Complete
#' match to "rf" or "svm" (random forest and support vector machine,
#' respectively).
#' @param regression_method method used in the regression. Complete match to
#' "rf", "svm" or "lm" (random forest and support vector machine, linear model).
#' @param seed a number. Seed used to compute the random forest and support
#' vector machine, if these are selected as binary or regression methods.
#' @return A list containting the call and the binary and regression models.
#'
#' @examples
#' class_model_train(
#' y = t1pks_class_abund,
#' x = dom_abund,
#' binary_method = "rf",
#' regression_method = "lm",
#' seed = 123)

class_model_train <- function(y,
                              x,
                              binary_method,
                              regression_method,
                              seed = 111) {
  return.list <- list()

  # subsselect present data ---------------------------------------------------

  subset <- y != 0
  x_present <- x[drop = F, subset, ]
  y_present <- y[subset]

  # direct regression when low absent counts  ---------------------------------

  if ( sum(!subset) < 10 ) {
    set.seed(seed = seed)

    if (regression_method == "rf") {
      model_r <- randomForest(y ~ . ,
                              data = x,
                              ntree = 1000,
                              replace = T,
                              nodesize = 1)
    }
    if (regression_method == "lm") {
      model_r <- lm(y ~ ., data = x)
    }
    if (regression_method == "svm") {
      model_r <- svm( y ~ ., data = x )
    }
    results <- list(call = c(binary_method = NULL, regression_method = regression_method, seed = seed),
                    binary_model = NULL,
                    regression_model = model_r)
    return.list <- results
  } else {

    # double models when enougth absent counts --------------------------------

    predictors_train <- x
    response_train <- y
    response_binary_train <- as.numeric(response_train !=0)
    predictors_present_train <- x_present
    response_present_train <- y_present

    # remove only zero columns ------------------------------------------------

    predictors_present_train <- predictors_present_train[, colSums(predictors_present_train) > 0]

    # train binary model ------------------------------------------------------

    set.seed(seed = seed)
    if (binary_method == "rf") {
      model_c <- randomForest(factor(response_binary_train) ~ .,
                              data = predictors_train,
                              ntree = 1000,
                              mtry = 1,
                              replace = T,
                              nodesize = 10)
    }
    if (binary_method == "svm") {
      predictors_train <- predictors_train[ ,colSums(predictors_present_train) > 0, drop = FALSE]
      model_c <- svm(factor(response_binary_train) ~ ., data = predictors_train )
    }

    # train regression model --------------------------------------------------

    set.seed(seed = seed)
    if (regression_method == "lm") {
      model_r <- lm(response_present_train ~ ., data = predictors_present_train)
    }
    if (regression_method == "rf") {
        model_r <- randomForest(response_present_train ~ . ,
                                data = predictors_present_train,
                                ntree = 1000,
                                replace = T,
                                nodesize = 1)
    }
    if (regression_method == "svm") {
      predictors_present_train <- predictors_present_train[ ,colSums(predictors_present_train) > 0, drop = FALSE]
      model_r <- svm(response_present_train ~ ., data = predictors_present_train)
    }

    results <- list(call = c(binary_method = binary_method, regression_method = regression_method, seed = seed),
                    binary_model = model_c,
                    regression_model = model_r)
    return.list <-  results
  }
  return(return.list)
}

# -----------------------------------------------------------------------------
# bgc class abundance prediction -----------------------------------------------------
# -----------------------------------------------------------------------------

#' Predict the class abundance
#'
#' @param x a matrix of data frame. These are the predictor variables
#' (i.e. domain abundances).
#' @param model_c a model object. This is the binary classification model
#' returned by class_model_train(). The predictor variables used to train
#' the model should be exactly the same as the variables in x.
#' @param model_r a model object. This is the regression model returned by
#'class_model_train(). The predictor variables used to train
#' the model should be exactly the same as the variables in x.
#' @return A numeric vector containing the predicted abundances.
#'
#' @examples
#' class_model_predict(
#' model_c = t1pks_binary_model,
#' model_r = t1pks_regression_model)

class_model_predict <- function(x,
                                model_c = NULL,
                                model_r) {

  if (is.null(model_c)) {

    pred_d <- predict(model_r, x)

  } else {

    pred_c <- predict(model_c, x)
    tmp <- pred_c == 1
    names(tmp) <- names(pred_c)
    pred_c <- tmp
    predictors_present <- x[drop = F, pred_c, ]
    pred_r <- predict(model_r, predictors_present)
    pred_d <- pred_c
    pred_d[!pred_c] <- 0
    pred_d[pred_c] <- pred_r

  }
  return(pred_d)
}

# -----------------------------------------------------------------------------
# wrap up prediction -----------------------------------------------------
# -----------------------------------------------------------------------------

#' Predict the class abundance wrap up script
#'
#' @param x a matrix of data frame. These are the predictor variables
#' (i.e. domain abundances).
#' @return A dataframe containing the predicted abundances.
#'
#' @examples
#' wrap_up_predict(x)

wrap_up_predict <- function(x) {

  pred <- list()
  used_models <- list()

  for ( b in names(models_list)) {

    predictors_var <- models_list[[b]]$doms
    check_predictors <- predictors_var %in% colnames(x)

    if ( length(predictors_var) >  sum(check_predictors)) {
      zeros_ncol <- sum(!check_predictors)
      zeros_nrow <- dim(x)[1]
      zeros2add <- matrix(0, nrow = zeros_nrow, ncol = zeros_ncol) %>% as.data.frame()
      colnames(zeros2add) <- predictors_var[!check_predictors]
      x <- cbind(x,zeros2add)
    }

    pred[[b]] <- class_model_predict(x = x[ , predictors_var, drop = F],
                                     model_c = models_list[[b]]$binary_model,
                                     model_r = models_list[[b]]$regression_model)

    }

  X <-  as.data.frame(pred)
  return(X)
}

