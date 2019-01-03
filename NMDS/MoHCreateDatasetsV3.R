parentfolder = "c:\\PDH\\Moh\\"
datafile = "MOHFinalSecondClean.csv"

mColInfo = c("factor", "factor", "factor", "factor", "factor", "factor", "integer", "factor", "factor", "factor"
             , "factor", "factor", "factor", "factor", "integer", "integer", "integer", "integer", "integer", "integer"
             , "integer", "integer", "factor", "factor", "factor", "character", "integer", "logical", "factor", 
             "factor", "factor"  )

df<- read.csv(paste0(parentfolder,datafile), header=TRUE
              ,comment.char = "",  skip =0,  check.names = FALSE
              ,na.strings=c("NA","NaN", ""),colClasses=mColInfo)

df$ethnicity3Groups = relevel(as.factor(df$ethnicity3Groups), ref = 'Not Maori/Pacific')
#df$Surg_grade_4_5 = relevel(as.factor(df$Surg_grade_4_5), ref = "1-3")
df$Acuity = relevel(as.factor(df$Acuity), ref = "elective")
df$Dep_score=as.ordered(df$Dep_score)
df$ASA=as.ordered(df$ASA)

str(df)
summary(df)

# to avoid 1<10<2<3......
str(df$Dep_score)
df$Dep_score = as.numeric(as.character(df$Dep_score))
df$Dep_score = as.ordered(df$Dep_score)

# to avoid 1<10<2<3......
df$opChapNum = as.numeric(as.character(df$opChapNum))
df$opChapNum = as.factor(df$opChapNum)
df$op02ChapNum = as.numeric(as.character(df$op02ChapNum))
df$op02ChapNum = as.factor(df$op02ChapNum)
df$op03ChapNum = as.numeric(as.character(df$op03ChapNum))
df$op03ChapNum = as.factor(df$op03ChapNum)


#true binary
# isEmergency,InHospitalMortality,cancerStatus,Mortality30,Mortality365,Mortality730
# binary cats -> recode to binary
# ,gender_F,gender_M
# ,IsSmoker_N,IsSmoker_Y,WasSmoker_N,WasSmoker_Y,HasDiabetesT1_N,HasDiabetesT1_Y,HasDiabetesT2_N,HasDiabetesT2_Y,IsNeuroTrauma_N,IsNeuroTrauma_Y
# ordinal
# opSeverity,ASA,Dep_score
# True cats
# ,eventType_ID,eventType_IM,eventType_IP
# ,opChapNum,op02ChapNum,op03ChapNum,
# ,ethnicity3Groups_Maori,ethnicity3Groups_Not Maori/Pacific,ethnicity3Groups_Pacific
levels(df$IsSmoker) <- c(0,1)
levels(df$WasSmoker) <- c(0,1)
levels(df$HasDiabetesT1) <- c(0,1)
levels(df$HasDiabetesT2) <- c(0,1)
levels(df$IsNeuroTrauma) <- c(0,1)
levels(df$gender) <- c(0,1)
names(df)[1] <- "IsMale"
names(df)[names(df) == 'gender'] <- 'IsMale'
names(df)[names(df) == 'isEmergency'] <- 'IsEmergency'
names(df)[names(df) == 'cancerStatus'] <- 'HasCancer'
df$HasCancer = as.factor(df$HasCancer)
levels(df$HasCancer) <- c(0,1)




str(df)
summary(df)
table(df$Dep_score)

#Split into train and test datasets
#Original - if we plan to split before imputing
dfOrg = df
set.seed(101)
sample <- sample.int(n = nrow(dfOrg), size = floor(.70*nrow(dfOrg)), replace = F)
trainOrg <- dfOrg[sample, ]
testOrg  <- dfOrg[-sample, ]
summary(dfOrg)

testOrgFull = testOrg #save for later to add mortality info back in (InHospitalMortality, Mortality30, Mortality365, Mortality730) to compare preds
#str(testOrgFull)
#strip out post event info from test set before imputing
#to mimic real life scenario
#str(testOrg)
testOrgStripped = testOrg[,c(-7, -23, -29, -30, -31)]
#str(testOrgStripped)



# ,Acuity_acute,Acuity_elective

write.csv(trainOrg, paste0(parentfolder,"MOHFinalPreImputeTrainV2.csv"), row.names=F,  na = "") 
write.csv(testOrgFull, paste0(parentfolder,"MOHFinalOrgTestV2.csv"), row.names=F,  na = "")  
#Our imputation will not have info on post op fields (this can also excluded via predictor matrix but we have other algos to tend with)
write.csv(testOrgStripped, paste0(parentfolder,"MOHFinalPreImputeTestV2.csv"), row.names=F,  na = "")  



#Create Complete Case Train and Test Dataset where records with missing values are dropped.
dfComplete = na.omit(df)
summary(dfComplete)

set.seed(101)
sample <- sample.int(n = nrow(dfComplete), size = floor(.70*nrow(dfComplete)), replace = F)
trainNM <- dfComplete[sample, ]
testNM  <- dfComplete[-sample, ]

par(mfrow=c(1,2))
plot(trainNM$InHospitalMortality)
plot(testNM$InHospitalMortality)

str(trainNM)

write.csv(trainNM, paste0(parentfolder,"MOHFinalCompleteCaseTrainV2.csv"), row.names=F,  na = "")  #11756
write.csv(testNM, paste0(parentfolder,"MOHFinalCompleteCaseTestV2.csv"), row.names=F,  na = "")  #5039

#ALTERNATIVE - sample then drop. Let's compare
trainNM2 <- na.omit(trainOrg)
testNM2 <-na.omit(testOrg)
par(mfrow=c(1,2))
plot(trainNM2$InHospitalMortality)
plot(testNM2$InHospitalMortality)

write.csv(trainNM2, paste0(parentfolder,"MOHFinalCompleteCaseALTTrainV2.csv"), row.names=F,  na = "")  #11739
write.csv(testNM2, paste0(parentfolder,"MOHFinalCompleteCaseALTTestV2.csv"), row.names=F,  na = "")  #5056

#install.packages("mice")

# require(mice)
# require(lattice)
# 
# set.seed(81)
# starttm = Sys.time()
# mohimptrain <- parlmice(trainOrg, m=40, maxit=40, cluster.seed = 81, print=TRUE)
# endtm = Sys.time()
# micetime = endtm - starttm
# micetime
# #Time difference of 7.759474 hours
# saveRDS(mohimptrain, file = paste0(parentfolder,"MiceMohFinalTrainV2.rds"))
# 
# 
# set.seed(81)
# starttm = Sys.time()
# mohimptest <- parlmice(testOrgStripped, m=40, maxit=40, cluster.seed = 81, print=TRUE)
# endtm = Sys.time()
# micetime2 = endtm - starttm
# micetime2
# #Time difference of 2.178301 hours
# saveRDS(mohimptest, file = paste0(parentfolder,"MiceMohFinalTestV2.rds"))
# 
# 
# plot(mohimptrain)





###########################################################
#missRanger
########################################################
#10 to 15 mins for mimic train
#install.packages("missRanger")
install.packages("data.table")
library(missRanger)
library(data.table)

#set.seed(81)
mrlist = list()
mrtimeslist = numeric(40)

for (i in 1:40)
{
  rseed = i*123+i^3
  starttm = Sys.time()
  mrlist[[i]] = missRanger(trainOrg, pmm.k = 3, maxiter=100, num.trees = 1000, seed=rseed, verbose = 2)
  endtm = Sys.time()
  mrlist[[i]]$.imp = i-1
  missrangertime = endtm - starttm
  missrangertime
  mrtimeslist[i] = missrangertime
}
mrtimeslist
mean(mrtimeslist)
sum(mrtimeslist)
saveRDS(mrtimeslist, file = paste0(parentfolder,"MohFinalMRTrainTimeV2s.rds"))
#mrtrain = do.call(rbind, mrlist)
#much faster
mrtrain = as.data.frame(data.table::rbindlist(mrlist))
saveRDS(mrtrain, file = paste0(parentfolder,"MohFinalMRTrainV2.rds"))
write.csv(mrtrain, paste0(parentfolder,"MohFinalMRTrainV2.csv"), row.names=F,  na = "")  


dupe = 0
nums <- unlist(lapply(mrlist[[1]], is.numeric))
#very crude checking
for (a in 1:length(mrtrain)) {
  for (b in 1:length(mrtrain)) {
    if (a != b && all(mrlist[[a]][,nums] == mrlist[[b]][,nums])) {
      dupe = dupe + 1
    }
  }
}
dupe

mrtestlist = list()
mrtesttimeslist = numeric(40)
for (i in 1:40)
{
  rseed = i*123+i^3
  starttm = Sys.time()
  mrtestlist[[i]] = missRanger(testOrgStripped, pmm.k = 3, maxiter=100, num.trees = 1000, seed=rseed, verbose = 2)
  endtm = Sys.time()
  mrtestlist[[i]]$.imp = i-1
  missrangertime = endtm - starttm
  missrangertime
  mrtesttimeslist[i] = missrangertime
}
mrtesttimeslist
mean(mrtesttimeslist)
saveRDS(mrtesttimeslist, file = paste0(parentfolder,"MohFinalMRTestTimesV2.rds"))
#mrtrain = do.call(rbind, mrlist)
#much faster
mrtest = as.data.frame(data.table::rbindlist(mrtestlist))
saveRDS(mrtest, file = paste0(parentfolder,"MohFinalMRTestV2.rds"))
write.csv(mrtest, paste0(parentfolder,"MohFinalMRTestV2.csv"), row.names=F,  na = "")  

dupe = 0
nums <- unlist(lapply(mrlist[[1]], is.numeric))
#very crude checking
for (a in 1:length(mrtest)) {
  for (b in 1:length(mrtest)) {
    if (a != b && all(mrlist[[a]][,nums] == mrlist[[b]][,nums])) {
      dupe = dupe + 1
    }
  }
}
dupe



