overdisp <- function(x, dependent.position = NULL, predictor.position = NULL, sig = NULL) {
  data.name <- base::deparse(substitute(x))
  dependent.name <- base::names(x)[dependent.position]
  predictors.name <- base::names(x)[predictor.position]
  var.names <- c(dependent.name, predictors.name)
  if(base::sum(base::as.numeric(base::grepl("[-+!#$%&*,/:;<=>?@^`|~]", var.names))) > 0){
    base::print("Please, remove all following characters like -+!#$%&*,/:;<=>?@^`|~ and quotation marks from the names of the selected variables. Then run overdisp again")
    stop()
  }
  f <- stats::as.formula(base::paste(dependent.name,sep = "~",base::paste(predictors.name,collapse="+")))
  model <- stats::glm(f, x, family = "poisson")
  if(is.null(sig) == T){
    step_model <- stats::step(model,trace=0,k=stats::qchisq(p=0.05,
                                                            df=1,
                                                            lower.tail=F))
  }
  else{
    step_model <- stats::step(model,trace=0,k=stats::qchisq(p=sig,
                                                            df=1,
                                                            lower.tail=F))
  }
  lambda <- step_model$fitted.values
  yast <- base::unlist((((x[,dependent.position]-lambda)^2)-x[,dependent.position])/lambda)
  aux.model <- stats::lm(yast~0+lambda)
  summary(aux.model)
  summary.amodel <- base::summary(aux.model)
  results <- base::list(statistic=c("Lambda t test score:"=summary.amodel$coefficients[3]),
                        p.value=summary.amodel$coefficients[4],
                        method="Overdispersion Test - Cameron & Trivedi (1990)",
                        data.name=data.name,alternative = "overdispersion if lambda p-value is less than or equal to the stipulated significance level")
  base::class(results) <- "htest"
  base::return(results)
}
