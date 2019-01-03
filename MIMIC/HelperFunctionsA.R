
library(plyr)
library(dplyr)
library(ggplot2)

prepDataSetNPE <- function(x) {
  names(x)[names(x) == 'ADMISSION_TYPE'] <- 'AdmissionType'
  names(x)[names(x) == 'ETHNICITY'] <- 'Ethnicity'
  names(x)[names(x) == 'LongTermMortality30d'] <- 'Mortality30d'
  names(x)[names(x) == 'LongTermMortality1year'] <- 'Mortality365'
  names(x)[names(x) == 'LongTermMortality2year'] <- 'Mortality730'
  names(x)[names(x) == 'LOS_ICU_days'] <- 'LOSinICU'
  
  x$RespiratoryRate = as.integer(x$RespiratoryRate)
  x$SodiumSerum = as.integer(x$SodiumSerum)
  
  
  x$GCSEyeScore <- as.numeric(as.character(x$GCSEyeScore))
  x$GCSMotorScore <- as.numeric(as.character(x$GCSMotorScore)) #reset
  x$GCSVerbalScore <- as.numeric(as.character(x$GCSVerbalScore)) #reset
  x$GCSEyeScore <- as.factor(x$GCSEyeScore)
  x$GCSMotorScore <- as.factor(x$GCSMotorScore) 
  x$GCSVerbalScore <- as.factor(x$GCSVerbalScore)
  
  
  x$PrimaryDiag <- as.numeric(as.character(x$PrimaryDiag)) #reset
  x$PrimaryDiag <- as.factor(x$PrimaryDiag)
  
  x$SecondaryDiag = as.numeric(as.character(x$SecondaryDiag))
  x$SecondaryDiag <- as.factor(x$SecondaryDiag)
  return (x)
}


#Final Transforms for train set before fitting
prepDataSet <- function(x) {
  names(x)[names(x) == 'ADMISSION_TYPE'] <- 'AdmissionType'
  names(x)[names(x) == 'ETHNICITY'] <- 'Ethnicity'
  names(x)[names(x) == 'LongTermMortality30d'] <- 'Mortality30d'
  names(x)[names(x) == 'LongTermMortality1year'] <- 'Mortality365'
  names(x)[names(x) == 'LongTermMortality2year'] <- 'Mortality730'
  names(x)[names(x) == 'LOS_ICU_days'] <- 'LOSinICU'
  
  x$RespiratoryRate = as.integer(x$RespiratoryRate)
  x$SodiumSerum = as.integer(x$SodiumSerum)

  x$GCSEyeScore <- as.numeric(as.character(x$GCSEyeScore))
  x$GCSMotorScore <- as.numeric(as.character(x$GCSMotorScore)) #reset
  x$GCSVerbalScore <- as.numeric(as.character(x$GCSVerbalScore)) #reset
  x$GCSEyeScore <- as.factor(x$GCSEyeScore)
  x$GCSMotorScore <- as.factor(x$GCSMotorScore) 
  x$GCSVerbalScore <- as.factor(x$GCSVerbalScore)

  x$InHospitalMortality <- as.numeric(as.character(x$InHospitalMortality))
  x$Mortality30d <- as.numeric(as.character(x$Mortality30d))
  x$Mortality365 <- as.numeric(as.character(x$Mortality365))
  
  x$InHospitalMortality <- as.factor(x$InHospitalMortality)
  x$Mortality30d <- as.factor(x$Mortality30d)
  x$Mortality365 <- as.factor(x$Mortality365)
  #x$Mortality730 <- as.factor(x$Mortality730)
  
  x$PrimaryDiag <- as.numeric(as.character(x$PrimaryDiag)) #reset
  x$PrimaryDiag <- as.factor(x$PrimaryDiag)
  
  x$SecondaryDiag = as.numeric(as.character(x$SecondaryDiag))
  x$SecondaryDiag <- as.factor(x$SecondaryDiag)
  
  
  
  # opSeverity to be converted into a two factor variable moving 4/5 together vs the others
  # x$Surg_grade_4_5 = ifelse(x$opSeverity == 5, yes = "4_5"
  #                           , no = ifelse(x$opSeverity == 4, yes = "4_5"
  #                                         , no = ifelse(is.na(x$opSeverity) == TRUE, yes = NA, no= "1-3")))
  # 
  # x$Surg_grade_4_5 = relevel(as.factor(x$Surg_grade_4_5), ref = "1-3")
  

  #str(x)
  return (x)
}


#https://www.r-bloggers.com/illustrated-guide-to-roc-and-auc/
#https://github.com/joyofdata/joyofdata-articles/blob/master/roc-auc/plot_pred_type_distribution.R
#modified to suit our purpose
plot_pred_type_distribution <- function(df, threshold) { 
  v <- rep(NA, nrow(df))
  v <- ifelse(df$pred >= threshold & df$outcome == 1, "TP", v)
  v <- ifelse(df$pred >= threshold & df$outcome == 0, "FP", v)
  v <- ifelse(df$pred < threshold & df$outcome == 1, "FN", v)
  v <- ifelse(df$pred < threshold & df$outcome == 0, "TN", v)
  
  df$pred_type <- v
  
  ggplot(data=df, aes(x=outcome, y=pred)) + 
    geom_violin(fill=rgb(1,1,1,alpha=0.6), color=NA) + 
    geom_jitter(aes(color=pred_type), alpha=0.6) +
    geom_hline(yintercept=threshold, color="red", alpha=0.6) +
    scale_color_discrete(name = "type") +
    labs(title=sprintf("Threshold at %.2f", threshold))
}

plot_pred_type_distribution2 <- function(df, threshold, titlename) { 
  v <- rep(NA, nrow(df))
  v <- ifelse(df$pred >= threshold & df$outcome == 1, "TP", v)
  v <- ifelse(df$pred >= threshold & df$outcome == 0, "FP", v)
  v <- ifelse(df$pred < threshold & df$outcome == 1, "FN", v)
  v <- ifelse(df$pred < threshold & df$outcome == 0, "TN", v)
  
  df$pred_type <- v
  
  ggplot(data=df, aes(x=outcome, y=pred)) + 
    geom_violin(fill=rgb(1,1,1,alpha=0.9), color=NA) + 
    geom_jitter(aes(color=pred_type), alpha=0.2, size=0.85) +
    geom_hline(yintercept=threshold, color="red", alpha=0.6) +
    geom_violin(fill=rgb(1,1,1,alpha=0.5), color=NA) + 
    scale_color_discrete(name = "type") +
    theme(plot.title = element_text(color="black", size=10, face="bold")) +
    labs(title=sprintf("%s\nDistibution of Predictions\n(%.2f Threshold)", titlename, threshold))
}

calculate_roc <- function(df, cost_of_fp, cost_of_fn, n=100) {
  tpr <- function(df, threshold) {
    sum(df$pred >= threshold & df$outcome == 1) / sum(df$outcome == 1)
  }
  
  fpr <- function(df, threshold) {
    sum(df$pred >= threshold & df$outcome == 0) / sum(df$outcome == 0)
  }
  
  cost <- function(df, threshold, cost_of_fp, cost_of_fn) {
    sum(df$pred >= threshold & df$outcome == 0) * cost_of_fp + 
      sum(df$pred < threshold & df$outcome == 1) * cost_of_fn
  }
  
  roc <- data.frame(threshold = seq(0,1,length.out=n), tpr=NA, fpr=NA)
  roc$tpr <- sapply(roc$threshold, function(th) tpr(df, th))
  roc$fpr <- sapply(roc$threshold, function(th) fpr(df, th))
  roc$cost <- sapply(roc$threshold, function(th) cost(df, th, cost_of_fp, cost_of_fn))
  
  return(roc)
}


plot_roc <- function(roc, threshold, cost_of_fp, cost_of_fn) {
  library(gridExtra)
  
  norm_vec <- function(v) (v - min(v))/diff(range(v))
  
  idx_threshold = which.min(abs(roc$threshold-threshold))
  
  col_ramp <- colorRampPalette(c("green","orange","red","black"))(100)
  col_by_cost <- col_ramp[ceiling(norm_vec(roc$cost)*99)+1]
  p_roc <- ggplot(roc, aes(fpr,tpr)) + 
    geom_line(color=rgb(0,0,1,alpha=0.3)) +
    geom_point(color=col_by_cost, size=1, alpha=0.5) +
    coord_fixed() +
    geom_line(aes(threshold,threshold), color=rgb(0,0,1,alpha=0.5)) +
    labs(title = sprintf("ROC")) + xlab("FPR") + ylab("TPR") +
    geom_hline(yintercept=roc[idx_threshold,"tpr"], alpha=0.5, linetype="dashed") +
    geom_vline(xintercept=roc[idx_threshold,"fpr"], alpha=0.5, linetype="dashed")
  
  p_cost <- ggplot(roc, aes(threshold, cost)) +
    geom_line(color=rgb(0,0,1,alpha=0.3)) +
    geom_point(color=col_by_cost, size=1, alpha=0.5) +
    labs(title = sprintf("cost function")) +
    geom_vline(xintercept=threshold, alpha=0.5, linetype="dashed")
  
  sub_title <- sprintf("threshold at %.2f - cost of FP = %d, cost of FN = %d", threshold, cost_of_fp, cost_of_fn)
  
  grid.arrange(p_roc, p_cost, ncol=2, sub=textGrob(sub_title, gp=gpar(cex=1), just="bottom"))
}