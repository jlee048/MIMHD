
library(plyr)
library(dplyr)
library(ggplot2)

prepNamesAndLevel <- function(df) {
  levels(df$IsSmoker) <- c(0,1)
  levels(df$WasSmoker) <- c(0,1)
  levels(df$HasDiabetesT1) <- c(0,1)
  levels(df$HasDiabetesT2) <- c(0,1)
  levels(df$IsNeuroTrauma) <- c(0,1)
  levels(df$gender) <- c(0,1)
  #names(df)[1] <- "IsMale"
  names(df)[names(df) == 'gender'] <- 'IsMale'
  names(df)[names(df) == 'isEmergency'] <- 'IsEmergency'
  names(df)[names(df) == 'cancerStatus'] <- 'HasCancer'
  df$HasCancer = as.factor(df$HasCancer)
  levels(df$HasCancer) <- c(0,1)
  return (df)
}

prepFactors  <- function(x) {
  x$IsMale = as.factor(x$IsMale)
  x$IsSmoker = as.factor(x$IsSmoker)
  x$WasSmoker = as.factor(x$WasSmoker)
  x$HasDiabetesT1 = as.factor(x$HasDiabetesT1)
  x$HasDiabetesT2 = as.factor(x$HasDiabetesT2)
  x$IsNeuroTrauma = as.factor(x$IsNeuroTrauma)
  x$IsEmergency = as.factor(x$IsEmergency)
  x$HasCancer = as.factor(x$HasCancer)
  return(x)
}

#Final Transforms for train set before fitting
prepDataSet <- function(x) {
  #Fix factor levels and ASA
  x$Dep_score = as.numeric(as.character(x$Dep_score))
  x$Dep_score = as.ordered(x$Dep_score)
  x$ASA = as.character(x$ASA)
  x$ASA = as.factor(x$ASA) #instead of ordinal to workaround ASA.L ASA.Q ASA.C issue
  x$opSeverity  = as.ordered(x$opSeverity)
  x$opChapNum  = as.factor(as.numeric(as.character(x$opChapNum)))
  x$op02ChapNum  = as.factor(as.numeric(as.character(x$op02ChapNum)))
  x$op03ChapNum  = as.factor(as.numeric(as.character(x$op03ChapNum)))
  
  #remap surgical specialties (opchapters)
  op_types01 = c("1_nervousSystem","other","other","other","other","7_respiratorySystem","8_vascularSystem"
                 ,"other","10_digestiveSystem","other","other","other","other","other","other")
  if (nlevels(x$op02ChapNum)==19) { 
    op_types02 = c("0_None","1_nervousSystem","other","other","other","other","other","7_respiratorySystem"
                   ,"8_vascularSystem","other","10_digestiveSystem","other","other","other","other"
                   ,"other","other","other","other")
  }
  if (nlevels(x$op02ChapNum)==20) { 
    op_types02 = c("0_None","1_nervousSystem","other","other","other","other","other","7_respiratorySystem"
                   ,"8_vascularSystem","other","10_digestiveSystem","other","other","other","other"
                   ,"other","other","other","other","other")
  }
  #table(x$op03ChapNum)
  if (nlevels(x$op03ChapNum)==19  & (sum(x$op03ChapNum==18)==0)) {
    op_types03 = c("0_None","1_nervousSystem","other","other","other","other","other","7_respiratorySystem"
                   ,"8_vascularSystem","other","10_digestiveSystem","other","other","other","other"
                   ,"other","other", "other","other") #removed "17_breast"
  }
  if (nlevels(x$op03ChapNum)==20) { 
    op_types03 = c("0_None","1_nervousSystem","other","other","other","other","other","7_respiratorySystem"
                   ,"8_vascularSystem","other","10_digestiveSystem","other","other","other","other"
                   ,"other","other", "18_radiationOncology","other","other") #removed "17_breast""
  }
  if (nlevels(x$op03ChapNum)==21) { 
    op_types03 = c("0_None","1_nervousSystem","other","other","other","other","other","7_respiratorySystem"
                   ,"8_vascularSystem","other","10_digestiveSystem","other","other","other","other"
                   ,"other","other", "other", "18_radiationOncology","other","other") #added "17_breast as other
  }
  
  
  x$surg01Spec = mapvalues(x=x$opChapNum, from = levels(as.factor(as.numeric(as.character(x$opChapNum)))), to=op_types01)
  x$surg01Spec = relevel(as.factor(x$surg01Spec), ref = "other")
  
  x$surg02Spec = mapvalues(x=x$op02ChapNum, from = levels(as.factor(as.numeric(as.character(x$op02ChapNum)))), to=op_types02)
  x$surg02Spec = relevel(as.factor(x$surg02Spec), ref = "0_None")
  
  x$surg03Spec = mapvalues(x=x$op03ChapNum, from = levels(as.factor(as.numeric(as.character(x$op03ChapNum)))), to=op_types03)
  x$surg03Spec = relevel(as.factor(x$surg03Spec), ref = "0_None")
  
  # opSeverity to be converted into a two factor variable moving 4/5 together vs the others
  x$Surg_grade_4_5 = ifelse(x$opSeverity == 5, yes = "4_5"
                            , no = ifelse(x$opSeverity == 4, yes = "4_5"
                                          , no = ifelse(is.na(x$opSeverity) == TRUE, yes = NA, no= "1-3")))
  
  x$Surg_grade_4_5 = relevel(as.factor(x$Surg_grade_4_5), ref = "1-3")
  
  x$ethnicity3Groups = relevel(as.factor(x$ethnicity3Groups), ref = 'Not Maori/Pacific')
  x$Acuity = relevel(as.factor(x$Acuity), ref = "elective")
  
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