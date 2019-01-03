

#n=names(df)
#cat(toString(shQuote(n)), "\n")
mfcolName=c("HADM_ID", "SUBJECT_ID", "ICUSTAY_ID", "ADMISSION_TYPE", "ADMISSION_LOCATION", "INSURANCE", "LANGUAGE", "RELIGION"
    , "MARITAL_STATUS", "ETHNICITY", "DIAGNOSiS", "ageAtAdmission", "ageAtDeath", "gender", "InHospitalMortality"
    , "ShortTermMortality1d", "ShortTermMortality3d", "LongTermMortality30d", "LongTermMortality1year"
    , "LOS_hours_icuicu_minprec", "LOS_ICU_days", "FIRST_CAREUNIT", "LAST_CAREUNIT", "dbsource", "HAS_CHARTEVENTS_DATA"
    , "HeartRate", "Temperature", "MeanArterialPressure", "GCSEyeScore", "GCSMotorScore", "GCSVerbalScore"
    , "RespiratoryRate", "phArterial", "Creatinine", "Hematocrit", "PotassiumSerum", "SodiumSerum", "WhiteBloodCount"
    , "PaO2FiO2", "PrimaryDiagICD9", "PrimaryDiag", "SecondaryDiagICD9", "SecondaryDiag")

# 1st column HADM_ID is factor due to data corruption e.g. "﻿182990" instead of 182990.
# ok since we are dropping it anyway
mfColInfo = c("factor", "integer", "integer", "factor", "factor", "factor", "factor", "factor", "factor", "factor"
              ,"factor", "numeric", "numeric", "factor", "factor", "factor", "factor", "factor", "factor", "numeric"
              ,"numeric", "factor", "factor", "factor", "factor", "numeric", "numeric", "numeric", "factor", "factor"
              ,"factor", "integer", "numeric", "numeric", "numeric", "numeric", "integer", "numeric", "numeric", "factor" 
              ,"factor", "factor", "factor" )

#parentfolder = "g:\\my drive\\uni\\dissertation\\data\\"
parentfolder = "c:\\PDH\\Apache\\"
datafile = paste0(parentfolder,"ApacheDatasetFinalV3.csv")

df<- read.csv(datafile, header = FALSE
              ,comment.char = "",  skip =0,  check.names = FALSE
              ,na.strings=c("NA","NaN", "NULL", ""),col.names = mfcolName, colClasses=mfColInfo) 

str(df)
colnames(df)

# Setting GCS scores as ordered factors
df$GCSEyeScore <- as.ordered(df$GCSEyeScore)
df$GCSMotorScore <- as.ordered(df$GCSMotorScore)
df$GCSVerbalScore <- as.ordered(df$GCSVerbalScore)


# df$SecondaryDiag <- as.integer(df$SecondaryDiag)
# df[which(is.na(df$SecondaryDiag)==TRUE),]$SecondaryDiag=0
# df$SecondaryDiag <- as.factor(df$SecondaryDiag)
# summary(df$SecondaryDiag)

#remove hadm_hd, subject_id, icustay_id, language, diagnosis, ageatdeath, has_chartevents_data, primaryicd9, secondaryicd9
df.data = df[,c(-(1:3),-7,-11,-13,-25,-40,-42)] 
summary(df.data)
str(df.data)
colnames(df.data)
#table(df.data$ADMISSION_LOCATION)
#table(df.data$FIRST_CAREUNIT)
#table(df.data$ADMISSION_TYPE)

# More fields to remove after feature selection and also due to computational constraints
#remove admission_location, insurance, religion, marital_status, Shorttermmortality1d, shorttermmortality3d, los_hours_icuicu_minprec, first_careunit, last_careunit, dbsource
df.data = df.data[,c(-2, -3, -4, -5, -10, -11, -14, -16, -17, -18)]    #-35,-36,-37)]
str(df.data)

#df.data = df.data[-(which(is.na(df.data$LOS_ICU_days) == 1)),]

summary(df.data)




#Flatten ethnicity from 41 to 8
table(df.data$ETHNICITY)
#e = levels(as.factor(df.data$ETHNICITY))
#paste(paste0('"', e, '"'), collapse = ", ")
#toString(sprintf('"%s"', e))
#cat(toString(shQuote(e)), "\n")
#"AMERICAN INDIAN/ALASKA NATIVE", "AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE", "ASIAN"
#, "ASIAN - ASIAN INDIAN", "ASIAN - CAMBODIAN", "ASIAN - CHINESE", "ASIAN - FILIPINO", "ASIAN - JAPANESE"
#, "ASIAN - KOREAN", "ASIAN - OTHER", "ASIAN - THAI", "ASIAN - VIETNAMESE", "BLACK/AFRICAN", "BLACK/AFRICAN AMERICAN"
#, "BLACK/CAPE VERDEAN", "BLACK/HAITIAN", "CARIBBEAN ISLAND", "HISPANIC OR LATINO"
#, "HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)", "HISPANIC/LATINO - COLOMBIAN", "HISPANIC/LATINO - CUBAN"
#, "HISPANIC/LATINO - DOMINICAN", "HISPANIC/LATINO - GUATEMALAN", "HISPANIC/LATINO - HONDURAN"
#, "HISPANIC/LATINO - MEXICAN", "HISPANIC/LATINO - PUERTO RICAN", "HISPANIC/LATINO - SALVADORAN"
#, "MIDDLE EASTERN", "MULTI RACE ETHNICITY", "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER", "OTHER"
#, "PATIENT DECLINED TO ANSWER", "PORTUGUESE", "SOUTH AMERICAN", "UNABLE TO OBTAIN", "UNKNOWN/NOT SPECIFIED"
#, "WHITE", "WHITE - BRAZILIAN", "WHITE - EASTERN EUROPEAN", "WHITE - OTHER EUROPEAN", "WHITE - RUSSIAN"                                 


# We map the above to the following
ethnicitySimplifiedList = c("AMERICAN INDIAN", "AMERICAN INDIAN", "ASIAN", "ASIAN", "ASIAN", "ASIAN", "ASIAN", "ASIAN"
                        , "ASIAN", "ASIAN", "ASIAN", "ASIAN", "BLACK", "BLACK", "BLACK", "BLACK", "HISPANIC/LATINO"
                        , "HISPANIC/LATINO", "HISPANIC/LATINO", "HISPANIC/LATINO", "HISPANIC/LATINO", "HISPANIC/LATINO"
                        , "HISPANIC/LATINO", "HISPANIC/LATINO", "HISPANIC/LATINO", "HISPANIC/LATINO", "HISPANIC/LATINO"
                        , "OTHER", "MULTI RACE ETHNICITY", "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER", "OTHER"
                        , "OTHER", "OTHER", "OTHER", "OTHER", "OTHER"
                        , "WHITE", "WHITE", "WHITE", "WHITE", "WHITE" )
library(plyr)
df.data$ETHNICITY = mapvalues(x=df.data$ETHNICITY, from = levels(as.factor(df.data$ETHNICITY)), to=ethnicitySimplifiedList)
#as.numeric(levels(df.data$ETHNICITY)[as.integer(df.data$ETHNICITY)])

summary(df.data$ETHNICITY)
str(df.data)
#df.data = df.data[,c(-25)]
df.data$ageAtAdmission = as.integer(df.data$ageAtAdmission)


summary(df.data)
#35821 observations of 24 variables


df.datasmall = df.data[1:1000,]
df.datamedium = df.data[1:10000,]


#write.csv(df.datasmall, "c:\\PDH\\ApachV3CleanSmall.csv", row.names=F,  na = "")
#write.csv(df.datamedium, "c:\\PDH\\ApacheV3CleanMedium.csv", row.names=F,  na = "")
write.csv(df.data, paste0(parentfolder,"ApacheV3Clean.csv"), row.names=F,  na = "")

#datafile = "c:\\PDH\\20180826\\Apache16andOverV6DiagsAsCatCleansed.csv"


#df$hasMissing = as.factor(df$hasMissing)
#df$hasMissingExclFiO2 = as.factor(df$hasMissingExclFiO2)
#df$hasMissingExclAPHFiO2 = as.factor(df$hasMissingExclAPHFiO2)
# dfNoMissing = df.data[which(df.data$hasMissing==0),]
# dfMissingValuesExclFiO2 = df.data[which(df.data$hasMissingExclFiO2==1),]
# dfMissingValuesExclAPHFiO2 = df.data[which(df.data$hasMissingExclAPHFiO2==1),]
# dfMissingValues = df.data[which(df.data$hasMissing==1),]
#rm(dfwithMissingValues)
# 
# dfNoMissing$InHospitalMortality=as.integer(dfNoMissing$InHospitalMortality)
# nums <- unlist(lapply(dfNoMissing, is.numeric))  
# dfNoMissing[ , nums]
# dta.r <- abs(cor(dfNoMissing[ , nums]))
#dfNoMissing$InHospitalMortality=as.factor(dfNoMissing$InHospitalMortality)
#summary(dfNoMissing)
#13218
#######################################
#creating datasets


str(df.data)
summary(df.data)

#Split into train and test datasets
#Original - if we plan to split before imputing
dfOrg = df.data
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
colnames(testOrg)
testOrgStripped = testOrg[,c(-5, -6, -7, -8)]
#str(testOrgStripped)
summary(testOrgStripped)
summary(trainOrg)
str(trainOrg)
table(trainOrg$ETHNICITY)

write.csv(trainOrg, paste0(parentfolder,"ApacheV3PreImputeTrain.csv"), row.names=F,  na = "") 
write.csv(testOrgFull, paste0(parentfolder,"ApacheV3OrgTest.csv"), row.names=F,  na = "")  
#Our imputation will not have info on post op fields (this can also excluded via predictor matrix but we have other algos to tend with)
write.csv(testOrgStripped, paste0(parentfolder,"ApacheV3PreImputeTest.csv"), row.names=F,  na = "")  




df.datacompletecase = na.omit(df.data)
#14233

#############################################
set.seed(101)
sample <- sample.int(n = nrow(df.datacompletecase), size = floor(.70*nrow(df.datacompletecase)), replace = F)
trainCC <- df.datacompletecase[sample, ]
testCC  <- df.datacompletecase[-sample, ]

write.csv(trainCC, paste0(parentfolder,"ApacheV3CompleteCaseTrain.csv"), row.names=F,  na = "")  #9963
write.csv(testCC, paste0(parentfolder,"ApacheV3CompleteCaseTest.csv"), row.names=F,  na = "")    #4270



## Now we create the mean and mode impute dataset
dfImputed = df.data

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

#dfImputed[which(is.na(dfImputed$RELIGION)),]$RELIGION='NOT SPECIFIED' #411
#dfImputed[which(is.na(dfImputed$MARITAL_STATUS)),]$MARITAL_STATUS=Mode(dfImputed$MARITAL_STATUS) #2062
#dfImputed[which(is.na(dfImputed$LOS_hours_icuicu_minprec)),]$LOS_hours_icuicu_minprec=mean(dfImputed$LOS_hours_icuicu_minprec, na.rm=T) #2
#dfImputed[which(is.na(dfImputed$LOS_ICU_days)),]$LOS_ICU_days=mean(dfImputed$LOS_ICU_days, na.rm=T) #2
summary(dfImputed)

dfImputed[which(is.na(dfImputed$HeartRate)),]$HeartRate=mean(dfImputed$HeartRate, na.rm=T) #380
dfImputed[which(is.na(dfImputed$Temperature)),]$Temperature=mean(dfImputed$Temperature, na.rm=T) #1404
dfImputed[which(is.na(dfImputed$MeanArterialPressure)),]$MeanArterialPressure=mean(dfImputed$MeanArterialPressure, na.rm=T) #1202

dfImputed[which(is.na(dfImputed$GCSEyeScore)),]$GCSEyeScore=median(as.integer(dfImputed$GCSEyeScore), na.rm=T) #365
dfImputed[which(is.na(dfImputed$GCSMotorScore)),]$GCSMotorScore=median(as.integer(dfImputed$GCSMotorScore), na.rm=T) #380
dfImputed[which(is.na(dfImputed$GCSVerbalScore)),]$GCSVerbalScore=median(as.integer(dfImputed$GCSVerbalScore), na.rm=T) #392

dfImputed[which(is.na(dfImputed$RespiratoryRate)),]$RespiratoryRate=mean(dfImputed$RespiratoryRate, na.rm=T) #398
dfImputed[which(is.na(dfImputed$phArterial)),]$phArterial=mean(dfImputed$phArterial, na.rm=T) #9334
dfImputed[which(is.na(dfImputed$Creatinine)),]$Creatinine=mean(dfImputed$Creatinine, na.rm=T) #189
dfImputed[which(is.na(dfImputed$Hematocrit)),]$Hematocrit=mean(dfImputed$Hematocrit, na.rm=T) #196
dfImputed[which(is.na(dfImputed$PotassiumSerum)),]$PotassiumSerum=mean(dfImputed$PotassiumSerum, na.rm=T) #348
dfImputed[which(is.na(dfImputed$SodiumSerum)),]$SodiumSerum=mean(dfImputed$SodiumSerum, na.rm=T) #350
dfImputed[which(is.na(dfImputed$WhiteBloodCount)),]$WhiteBloodCount=mean(dfImputed$WhiteBloodCount, na.rm=T) #186
dfImputed[which(is.na(dfImputed$PaO2FiO2)),]$PaO2FiO2=mean(dfImputed$PaO2FiO2, na.rm=T) #20072


summary(dfImputed)
###################################################################################
set.seed(101)
sample <- sample.int(n = nrow(dfImputed), size = floor(.70*nrow(dfImputed)), replace = F)
trainImpute <- dfImputed[sample, ]
testImpute  <- dfImputed[-sample, ]
par(mfrow=c(1,2))
plot(trainImpute$InHospitalMortality)
plot(testImpute$InHospitalMortality)


write.csv(trainImpute, paste0(parentfolder,"ApacheV3MeanModeTrain.csv"), row.names=F,  na = "")  #25074
write.csv(testImpute, paste0(parentfolder,"ApacheV3MeanModeTest.csv"), row.names=F,  na = "")    #10747



#MissForest block,don't use anymore
# 
# #need to remove last 4 columns
# #df.dataForMI = df.data[,c(-(35:38))]
# 
# #install.packages("doParallel")
# #install.packages("missForest")
# require(doParallel)
# #registerDoParallel()
# registerDoParallel(cores=4)
# getDoParWorkers()
# library(missForest)
# 
# df.dataForMI = df.data
# set.seed(81)
# mffullfd.start = Sys.time()
# imp.mffullforests = missForest(df.dataForMI, variablewise = TRUE, verbose = TRUE, parallelize = 'forests')
# mffullfd.end = Sys.time()
# mffull.forestsduration = mffullfd.end - mffullfd.start
# mffull.forestsduration
# #Time difference of 1.530393 days
# #Time difference of 11.6941 hours
# summary(imp.mffullforests$ximp)
# str(imp.mffullforests$ximp)
# 
# saveRDS(imp.mffullforests, file = "c:\\PDH\\MFImpApacheDatasetFinalV3.rds")
# write.csv(imp.mffullforests$ximp, file = "c:\\PDH\\MFImpApacheDatasetFinalV3.csv", row.names=F)
# write.csv(imp.mffullforests$OOBerror, file = "c:\\PDH\\MFImpApacheDatasetFinalV3OOBerror.csv")
# 
# save.image(file = "c:\\PDH\\my_work_space_20180909.RData")
# 
# ############################################################
# 
# #df.data = df[,c(-(1:3),-7,-11,-13,-25,-40,-42)]
# mfColInfo3 = c("factor", "factor", "integer", "factor", "factor", "factor", "factor", "numeric", "numeric", "numeric"
#                ,"numeric", "factor", "factor", "factor", "numeric", "numeric", "numeric", "numeric", "numeric"
#                , "numeric", "numeric", "numeric","factor", "factor")
# 
# imputeddatafile = "c:\\PDH\\MFImpApacheDatasetFinalV3.csv"
# 
# dfmi<- read.csv(imputeddatafile, header=TRUE
#                 ,comment.char = "",  skip =0,  check.names = FALSE
#                 ,na.strings=c("NA","NaN", "", "NULL"), colClasses=mfColInfo3)
# 
# 
# summary(dfmi)
# str(dfmi)
# 
# ###################################################################################
# set.seed(101)
# sample <- sample.int(n = nrow(dfmi), size = floor(.70*nrow(dfmi)), replace = F)
# trainMI <- dfmi[sample, ]
# testMI  <- dfmi[-sample, ]
# par(mfrow=c(1,2))
# plot(trainMI$InHospitalMortality)
# plot(testMI$InHospitalMortality)
# 
# write.csv(trainMI, "c:\\PDH\\ApacheDatasetFinalV3MFMITrain.csv", row.names=F,  na = "")  #25074
# write.csv(testMI, "c:\\PDH\\ApacheDatasetFinalV3MFMITest.csv", row.names=F,  na = "")    #10747




# 
# 
# ## MICE
# set.seed(81)
# mffullfd.start = Sys.time()
# mimicimpfull <- mice(df.data, maxit=40)
# mffullfd.end = Sys.time()
# mffull.duration = mffullfd.end - mffullfd.start
# mffull.duration
# 
# #imp40 <- mice.mids(imp, maxit=35, print=F)
# #plot(imp40)
# plot(mimicimpfull)
# stripplot(mimicimpfull)
# 
# saveRDS(mimicimpfull, file = paste0(parentfolder,"ApacheV3MICEFull.rds"))
# #write.csv(mimicimpfull$ximp, file = "c:\\PDH\\MFImpApacheDatasetFinalV3.csv", row.names=F)



require(mice)
require(lattice)

set.seed(81)
starttm = Sys.time()
mohimptrain <- parlmice(trainOrg, m=40, maxit=40, cluster.seed = 81, print=TRUE)
endtm = Sys.time()
micetime = endtm - starttm
micetime
#Time difference of 7.759474 hours for moh
#Time difference of 6.826492 hours for mimic
#Time difference of 7.759474 hours for moh
saveRDS(mohimptrain, file = paste0(parentfolder,"ApacheV3MICETrain.rds"))


set.seed(81)
starttm = Sys.time()
mohimptest <- parlmice(testOrgStripped, m=40, maxit=40, cluster.seed = 81, print=TRUE)
endtm = Sys.time()
micetime2 = endtm - starttm
micetime2
#Time difference of 2.178301 hours for moh
#Time difference of 2.551298 hours for mimic
#Time difference of 2.178301 hours for moh
saveRDS(mohimptest, file = paste0(parentfolder,"ApacheV3MICETest.rds"))


plot(mohimptrain)


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
saveRDS(mrtimeslist, file = paste0(parentfolder,"ApacheV3MRTrainTimes.rds"))
#mrtrain = do.call(rbind, mrlist)
#much faster
mrtrain = as.data.frame(data.table::rbindlist(mrlist))
saveRDS(mrtrain, file = paste0(parentfolder,"ApacheV3MRTrain.rds"))
write.csv(mrtrain, paste0(parentfolder,"ApacheV3MRTrain.csv"), row.names=F,  na = "")  


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
saveRDS(mrtesttimeslist, file = paste0(parentfolder,"ApacheV3MRTestTimes.rds"))
#mrtrain = do.call(rbind, mrlist)
#much faster
mrtest = as.data.frame(data.table::rbindlist(mrtestlist))
saveRDS(mrtest, file = paste0(parentfolder,"ApacheV3MRTest.rds"))
write.csv(mrtest, paste0(parentfolder,"ApacheV3MRTest.csv"), row.names=F,  na = "")  

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

