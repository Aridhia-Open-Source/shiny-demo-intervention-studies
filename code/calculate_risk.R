load("data/original_parr30_coefficients.rda")
load("data/original_parr30_constant.rda")


calculate_risk <- function(x, ...) {
  UseMethod("calculate_risk")
}


calculate_risk.formula <- function(x, train_data, test_data = train_data, family = "binomial", ...) {
  
  extra_args <- match.call(expand.dots = FALSE)$...
  glm_args <- c(names(formals(glm)), names(formals(glm.control)))
  glm_extras <- extra_args[names(extra_args) %in% glm_args]
  
  model <- do.call(glm, c(list(x, data = train_data, family = family), glm_extras))
  
  calculate_risk(model, newdata = test_data, ...)
  
}


calculate_risk.glm <- function(x, type = "response", ...) {
  
  predict(x, type = type, ...)
  
}

## include a dataframe matching trusts to their original coefs in the package?
calculate_risk.data.frame <- function(x, coefficients = original_parr30_coefficients, constant = original_parr30_constant,
                                      trust_coefficients = trusts, ...) {
  df <- x
  
  if (!is.factor(df$imd_score)) {
    df$imd_score <- cut(df$imd_score, breaks =  c(0, 10, 15, 25, 40, 50, max(df$imd_score) + 1))
  }
  
  df[, (ncol(df) + 1):(ncol(df) + length(levels(df$imd_score)))] <- lapply(levels(df$imd_score), function(i) as.numeric(df$imd_score == i))
  names(df)[(ncol(df) + 1 - length(levels(df$imd_score))):ncol(df)] <- paste0("imd_score", seq_along(levels(df$imd_score)))
  
  df$age_at_discharge <- df$age_at_discharge^2
  
  
  if (is.null(trust_coefficients) || is.null(df$trust_code)) {
    trust <- list(coefficient = 0)
  } else {
    df$sort_id <- seq_len(nrow(df))       # merge in base R does not preserve order of either merged dataframe so add a temporary id column to do this
    trust <- merge(trust_coefficients, df, by.x = "trust_code", by.y = "trust_code")
    trust <- trust[order(trust$sort_id), ]
  }
  
  
  if (is.null(names(coefficients))) { 
    df <- df[, -which(names(df) %in% c("spell_id", "imd_score", "trust_code", "sort_id", "readmitted"))]
  } else {
    df <- df[, names(coefficients)]
  }
  
  
  score <- as.vector((as.matrix(df) %*% coefficients) + constant + trust$coefficient)
  
  exp(score) / (1 + exp(score))
  
  
  
}