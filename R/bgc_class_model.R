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
# bgc class abundance modeling ------------------------------------------------
# -----------------------------------------------------------------------------

#' Generate the BGC class models.
#'
#' @param y a numeric vector. This is the response variable
#' (i.e. class abundances).
#' @param x a matrix of data frame. These are the predictor variables
#' (i.e. domain abundances).
#' @param binary_method method used in the binary classification. Complete
#' match to "rf", "svm" or "xgb" (random forest, support vector machine, and
#' extreme gradient boost, respectively).
#' @param regression_method method used in the regression. Complete match to
#' "lm", "rf", "svm" or "xgb" (linear model, random forest, support vector
#' machine and extreme gradient boost, respectively).
#' @param seed a number. Seed used to compute the random forest and support
#' vector machine, if these are selected as binary or regression methods.
#' @return A list containting the call, and the binary and regression models.
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
                              seed = 123) {
  return.list <- list()

  # check classification and regression syntaxis  -----------------------------
  if (is.null(binary_method) == F ) {
    if ( !binary_method %in% c("rf","xgb","svm") ) {
      warning("binary method not found")
      return(NULL)
    }
    if ( !regression_method %in% c("rf","xgb","svm","lm") ) {
      warning("regression method not found")
      return(NULL)
    }
  }

  # subsselect present data ---------------------------------------------------

  subset <- y != 0
  x_present <- x[drop = F, subset, ]
  y_present <- y[subset]

  # direct regression when low absent counts  ---------------------------------

  if ( sum(!subset) < 10 | is.null(binary_method) == T) {
    set.seed(seed = seed)

    # remove only zero columns ------------------------------------------------

    x <- x[, colSums(x) > 0, drop =  F]

    # train regressions -------------------------------------------------------

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

    if (regression_method == "xgb") {
      x <- as.matrix(x) %>%
           apply(X = ., MARGIN = 2, FUN = as.numeric)

      model_r <- xgboost(label = y,
                         data = x,
                         booster = "gblinear",
                         nthread = 2,
                         nrounds = 8,
                         objective = "reg:linear",
                         verbose = F)
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

    predictors_present_train <- predictors_present_train[, colSums(predictors_present_train) > 0, drop =  F]

    if ( ncol(predictors_present_train) == 0 ) {
      warning("not enough predictor values")
      return(NULL)
    }

    if ( ncol(predictors_present_train) > 0 ) {
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


      if (binary_method == "xgb") {
        predictors_train <- as.matrix(predictors_train) %>%
                            apply(X = ., MARGIN = 2, FUN = as.numeric)

        model_c <- xgboost(label = response_binary_train,
                           data = predictors_train,
                           max_depth = 8,
                           eta = 1,
                           nthread = 2,
                           nrounds = 8,
                           objective = "binary:logistic",
                           verbose = F)
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

      if (regression_method == "xgb") {
        predictors_present_train <- as.matrix(predictors_present_train) %>%
                                    apply(X = ., MARGIN = 2, FUN = as.numeric)
        model_r <- xgboost(label = response_present_train,
                           data = predictors_present_train,
                           booster = "gblinear",
                           nthread = 2,
                           nrounds = 8,
                           objective = "reg:linear",
                           verbose = F)
      }

      results <- list(call = c(binary_method = binary_method, regression_method = regression_method, seed = seed),
                      binary_model = model_c,
                      regression_model = model_r)
      return.list <-  results

    }
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

    if (class(model_r)[1] == "xgb.Booster") {
      x <- as.matrix(x) %>%
           apply(X = ., MARGIN = 2, FUN = as.numeric)
    }

    pred_d <- predict(model_r, x)

  } else {

    if (class(model_c)[1] == "xgb.Booster") {
      x_matrix <- as.matrix(x) %>%
                  apply(X = ., MARGIN = 2, FUN = as.numeric)
      pred_c <- predict(model_c, x_matrix)
      pred_c <- as.numeric(pred_c > 0.5)
    } else {
      pred_c <- predict(model_c, x)
    }

    tmp <- pred_c == 1
    names(tmp) <- names(pred_c)
    pred_c <- tmp
    predictors_present <- x[drop = F, pred_c, ]

    if (class(model_r)[1] == "xgb.Booster") {
      predictors_present <- as.matrix(predictors_present) %>%
                            apply(X = ., MARGIN = 2, FUN = as.numeric)
    }

    pred_r <- predict(model_r, predictors_present)
    pred_d <- pred_c
    pred_d[!pred_c] <- 0
    pred_d[pred_c] <- pred_r

  }
  pred_d[pred_d < 0] <- 0
  return(pred_d)
}

# -----------------------------------------------------------------------------
# wrap up prediction -----------------------------------------------------
# -----------------------------------------------------------------------------

#' Predict the class abundance wrap up script
#'
#' @param x a matrix of data frame. These are the predictor variables
#' (i.e. domain abundances).
#' @param m a list with all the models, as generated by class_model_train.
#' @return A dataframe containing the predicted abundances.
#'
#' @examples
#' wrap_up_predict(x)

wrap_up_predict <- function(x, m = OMs_model) {

  pred <- list()
  used_models <- list()

  for (b in names(m)) {

    predictors_var <- m[[b]]$doms
    check_predictors <- predictors_var %in% colnames(x)

    if ( length(predictors_var) >  sum(check_predictors)) {
      zeros_ncol <- sum(!check_predictors)
      zeros_nrow <- dim(x)[1]
      zeros2add <- matrix(0, nrow = zeros_nrow, ncol = zeros_ncol) %>% as.data.frame()
      colnames(zeros2add) <- predictors_var[!check_predictors]
      x <- cbind(x,zeros2add)
    }

    pred[[b]] <- class_model_predict(x = x[ , predictors_var, drop = F],
                                     model_c = m[[b]]$binary_model,
                                     model_r = m[[b]]$regression_model)

    }

  X <-  as.data.frame(pred)
  return(X)
}

