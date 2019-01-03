from midas import Midas

from sklearn.preprocessing import MinMaxScaler
import numpy as np
import pandas as pd
from datetime import datetime as dt
from itertools import groupby

def back_from_dummies(df):
    result_series = {}
    # Find dummy columns and build pairs (category, category_value)
    dummmy_tuples = [(col.split("_")[0],col) for col in df.columns if "_" in col]
    # Find non-dummy columns that do not have a _
    non_dummy_cols = [col for col in df.columns if "_" not in col]
    # For each category column group use idxmax to find the value.
    for dummy, cols in groupby(dummmy_tuples, lambda item: item[0]):
        #Select columns for each category
        dummy_df = df[[col[1] for col in cols]]
        # Find max value among columns
        max_columns = dummy_df.idxmax(axis=1)
        # Remove category_ prefix
        result_series[dummy] = max_columns.apply(lambda item: item.split("_")[1])
    # Copy non-dummy columns over.
    for col in non_dummy_cols:
        result_series[col] = df[col]
    # Return dataframe of the resulting series
    return pd.DataFrame(result_series)


#True categoricals which need to be one hotted
#categoricalMOH = ["eventType","opChapNum","op02ChapNum","op03ChapNum","ethnicity3Groups","Acuity"]
categorical = ["AdmissionType","Ethnicity","gender","PrimaryDiag","SecondaryDiag"] #,"InHospitalMortality","LongTermMortality30d","LongTermMortality1year"
#posteventMOH = ["LOS","InHospitalMortality","Mortality30","Mortality365","Mortality730"]
postevent = ["InHospitalMortality","LongTermMortality30d","LongTermMortality1year","LOS_ICU_days"]
#ordinals and binaries are left alone
#ordinals = ["Dep_score","opSeverity","ASA"]
#needsimputationMOH = ["opSeverity","ASA","IsEmergency","Dep_score"]
needsimputation = ["HeartRate","Temperature","MeanArterialPressure","GCSEyeScore","GCSMotorScore"
    ,"GCSVerbalScore","RespiratoryRate","phArterial","Creatinine","Hematocrit"
    ,"PotassiumSerum","SodiumSerum","WhiteBloodCount","PaO2FiO2"]


m = 40  # This is the number of imputed datasets created, using 50 when running for real
epochs = 250  # This should be set to 500 when it is run for real.
doVerbose = True  # This should be set to False for the real run.
debug = False
layers = [128, 128] #1.08, 1.09 (64,64), 1.047, 1.056 (128,128), 1.017, 1.055 (128x3)
doTrain = True
doTargetTrain = True
savePath = "C:\\PDH\\MIDAS\\tmp2\\"
datasetName = "MimicMidasE250m40L128Final"
fullSavePath = savePath + datasetName

#reorder numerics first then categories
#postevents to the end
def  reorderdf(dfe):
    dfe_0 = dfe
    dfe_0.columns.str.strip()
    dfe_1 = dfe_0[categorical]    # Create a dataframe of just the categorical columns
    dfe_0.drop(categorical, axis=1, inplace=True)
    dfe_2 = pd.concat([dfe_0,dfe_1], axis=1)
    return dfe_2

# encode
def encodedf(dfe):
    dfe_0 = dfe
    dfe_0.columns.str.strip()
    dfe_1 = dfe_0[categorical]  # Create a dataframe of just the categorical columns
    dfe_0.drop(categorical, axis=1, inplace=True)
    constructor_list = [dfe_0]
    columns_list1 = []  # names of one hot encoded columns stored here
    # one hot encoding
    dfe_1 = dfe_1.astype('category')
    for column in dfe_1.columns:
        na_temp = dfe_1[column].isnull()
        temp = pd.get_dummies(dfe_1[column])
        # temp.add_prefix(column+'_')         #add the column name as prefix since col by col dummification omits them
        temp.columns = [column + '_' + str(col) for col in temp.columns]
        temp[na_temp] = np.nan  # put the nas back in
        constructor_list.append(temp)
        columns_list1.append(list(temp.columns.values))
    # constructor_list.append(dfe_0) # add the non categoricals df back
    dfe_0 = pd.concat(constructor_list, axis=1)
    return dfe_0, columns_list1

    # data_pe = data_nonimpute[postevent]
    # data_npe = data_nonimpute.drop(postevent, axis=1, inplace=False)
    # data_npe_cat = data_npe[categorical]
    # data_npe_num = data_npe.drop(categorical, axis=1, inplace=False)
    # #data_0 = pd.concat([data_impute_target_cat, data_impute_target_num, data_additional], axis=1)
    # data_r = pd.concat([data_imputation_target, data_npe_cat, data_npe_num, data_pe], axis=1)
    # data_r.reset_index()
    # #data_0.to_csv(fullSavePath + "test.csv", index=False)
    # print(data_r.shape)
    # print(data_r.head())
    # print(data_r.columns)
    # return data_r

#min max scaling - doesnt handle na, so we sub and fill them back in
def minmaxer(dfm):
    dfm_0 = dfm.copy()
    print(dfm_0.shape)
    scaler = MinMaxScaler()
    na_loc = dfm_0.isnull()
    dfm_1 = dfm_0.fillna(dfm_0.min(), inplace= False)
    dfm_1 = pd.DataFrame(scaler.fit_transform(dfm_1), columns= dfm_1.columns)
    dfm_2 = dfm_1.copy()
    dfm_2[na_loc] = np.nan
    return dfm_2, scaler


df = pd.read_csv('c:\\pdh\\apache\\ApacheV3PreImputeTrain.csv')
df.rename(columns={'ADMISSION_TYPE': 'AdmissionType','ETHNICITY': 'Ethnicity'}, inplace=True)
print(df.head())
print(df.shape)
trainlength = len(df)

#load test
#dft = pd.read_csv('c:\pdh\moh\MOHFinalPreImputeTestV2.csv')
dft = pd.read_csv('c:\\pdh\\apache\\Apachev3OrgTest.csv')
dft.rename(columns={'ADMISSION_TYPE': 'AdmissionType','ETHNICITY': 'Ethnicity'}, inplace=True)
print(dft.head())
print(dft.shape)
testlength = len(dft)



data_imputation_target = df[needsimputation]
data_additional = df.drop(needsimputation, axis=1, inplace=False)
data_additional_ordered = reorderdf(data_additional)
data_additional_ordered_org = data_additional_ordered.copy()
#data_imputation_ordered = reorderdf(data_imputation_target)

# keep original df for imp=0 but need to ensure order is same
orgdf = pd.concat([data_imputation_target,data_additional_ordered], axis=1)
orgdf.insert(0, '.id', range(0, len(orgdf)))
orgdf.insert(0, '.imp', 0)
orgdf.to_csv(fullSavePath + "ordered.csv", index=False)


#split to needs impute and additional data
datat_imputation_target = dft[needsimputation]
datat_additional = dft.drop(needsimputation, axis=1, inplace=False)
datat_additional_ordered = reorderdf(datat_additional)
datat_additional_ordered_org = datat_additional_ordered.copy()
#data_imputation_ordered = reorderdf(data_imputation_target)

#org copy
# keep original df for imp=0 but need to ensure order is same
orgdft = pd.concat([datat_imputation_target,datat_additional_ordered], axis=1)
orgdft.insert(0, '.id', range(0, len(orgdft)))
orgdft.insert(0, '.imp', 0)
orgdft.to_csv(fullSavePath + "TESTordered.csv", index=False)


# df = df.append(dft, axis = 2)
# data_imputation_target = df[needsimputation]
# data_additional = df.drop(needsimputation, axis=1, inplace=False)
# data_additional_ordered = reorderdf(data_additional)
#data_imputation_ordered = reorderdf(data_imputation_target)
print(data_imputation_target.shape)
data_imputation_target = data_imputation_target.append(datat_imputation_target)
print(data_imputation_target.shape)
print(data_additional_ordered.shape)
data_additional_ordered = data_additional_ordered.append(datat_additional_ordered)
print(data_additional_ordered.shape)

# datatest_0 = reorderdf(dft)
# torgdf = datatest_0.copy()
# torgdf.insert(0, '.id', range(0, len(torgdf)))
# torgdf.insert(0, '.imp', 0)
# torgdf.to_csv(fullSavePath + "orderedtest.csv", index=False)

#dataimpute, di_columns_list = encodedf(data_imputation_target)
#We combine to encode to ensure all levels are consistently encoded properly,
#  then split again before training and testing models
dataimpute=data_imputation_target
dataimpute.to_csv(fullSavePath+"DIencoded.csv", index=False)
print(fullSavePath+"DIencoded.csv")
dataadditional, da_columns_list = encodedf(data_additional_ordered)
dataadditional.to_csv(fullSavePath+"DAencoded.csv", index=False)
print(fullSavePath+"DAencoded.csv")


di = pd.read_csv(fullSavePath+"DIencoded.csv")
print(di.shape)
# datatest_0, columns_listtest = encodedf(datatest_0)
# datatest_0.to_csv(fullSavePath+"encodedtest.csv", index=False)
dataimpute, discaler = minmaxer(di)
dataimpute.to_csv(fullSavePath+"DIscaled.csv", index=False)
print(fullSavePath+"DIscaled.csv")

da = pd.read_csv(fullSavePath+"DAencoded.csv")
print(da.shape)
dataadditional, dascaler = minmaxer(da)
dataadditional.to_csv(fullSavePath+"DAscaled.csv", index=False)
print(fullSavePath+"DAscaled.csv")

datatestimpute = dataimpute.iloc[trainlength:]
print(datatestimpute.shape)
datatestimpute.to_csv(fullSavePath+"TESTDIscaled.csv", index=False)
print(fullSavePath+"TESTDIscaled.csv")

dataimpute = dataimpute.iloc[0:(trainlength)]
print(dataimpute.shape)
dataimpute.to_csv(fullSavePath+"TRAINDIscaled.csv", index=False)
print(fullSavePath+"TRAINDIscaled.csv")

datatestadditional = dataadditional.iloc[trainlength:]
print(datatestadditional.shape)
datatestadditional.to_csv(fullSavePath+"TESTDAscaled.csv", index=False)
print(fullSavePath+"TESTDAscaled.csv")

dataadditional = dataadditional.iloc[0:(trainlength)]
print(dataadditional.shape)

dataadditional.to_csv(fullSavePath+"TRAINDAscaled.csv", index=False)
print(fullSavePath+"TRAINDAscaled.csv")
###TODO: fillnas



# datatest_0, scalertest = minmaxer(datatest_0)
# datatest_0.to_csv(fullSavePath+"scaledtest.csv", index=False)

# split out to two dfs pre encoding scaling
# data_0.reset_index()
# fullcolumns = data_0.columns
# data_impute_target = data_0[needsimputation]
# data_additional = data_0.drop(needsimputation, axis=1, inplace=False)


# Perform the imputation - including building the model
#set softmax_adj =  1/(number of softmaxes)
print(categorical)
sma = 1.0/len(categorical)
# don't need sma for moh d/s if we use additional data

#imputer = Midas(layer_structure=layers, train_batch=64, vae_layer=False, seed=42, softmax_adj=sma, savepath=fullSavePath)
#imputer.build_model(data_0, softmax_columns=columns_list)
#imputer.build_model(imputation_target=data_impute_target, softmax_columns=columns_list, additional_data=data_additional)

imputer = Midas(layer_structure=layers, train_batch=64, vae_layer=False, seed=42, savepath=fullSavePath)
# use blank softmax columns coz we moved them to the additional data df
imputer.build_model(imputation_target=dataimpute, softmax_columns=[], additional_data=dataadditional)


# startTime = dt.now()
# imputer.overimpute(training_epochs= 100, report_ival= 10,
#                    report_samples= 5, verbosity_ival = 10, plot_all = False)
# endTime = dt.now()
# print("Runtime for overimputing " + datasetName + ": ", endTime - startTime)

if (doTrain):
    print("training on train set")
    startTime = dt.now()
    imputer.train_model(training_epochs=epochs, verbosity_ival=1, verbose=doVerbose)
    endTime = dt.now()
    print("Runtime for training " + datasetName + ": ", endTime - startTime)

# Generate the 'm' number of datasets
print("Generating samples")
imputer.batch_generate_samples(m=m)

#imputer.batch_generate_samples(m=m)

def outputdatasets(columns_list1, data_additional1, imputer1, orgdf1, fullSavePath1, orgdataadditional,  suffix=''):
    #list of all categorical columns
    flat_col_list = [item for sublist in columns_list1 for item in sublist]
    n = 0
    for dataset in imputer1.output_list:
        n=n+1
        # take off -ves to 0
        if (debug):
            dataset.to_csv(fullSavePath1 + "raw" + suffix + str(n) + ".csv", index=False)
        print(fullSavePath1 + "raw" + suffix + str(n) + ".csv")

        # make all -ves into 0
        dataset[dataset < 0] = 0

        #data_2 = pd.DataFrame(scaler.inverse_transform(data_1a), columns=dataset.columns)
        # add back postevent fields
        #data_1a = pd.concat([dataset, data_additional1], axis=1)
        data_2 = pd.DataFrame(discaler.inverse_transform(dataset), columns=dataset.columns)
        # use the orginal nonimputed instead
        # data_2ad = pd.DataFrame(dascaler.inverse_transform(data_additional1), columns=data_additional1.columns)

        # round up floating pt errors after inverse scaling
        data_2 = data_2.round(6)
        #data_2ad = data_2ad.round(3)
        #data_2.to_csv(fullSavePath + "descaled_" + suffix + str(n) + ".csv", index=False)

        # convert encoded dummies back to categorical columns
        # ddd = data_2ad[flat_col_list]
        # data_2adc = back_from_dummies(ddd)
        #data_3.to_csv(fullSavePath + "catdecoded_" + suffix + str(n) + ".csv", index=False)

        # create non cats and change back to int64 since scaling converted everything to float64
        #data_2ad.drop(flat_col_list, axis=1, inplace=True)
        decimals = pd.Series([0, 0, 0, 0], index=['ageAtAdmission', 'SodiumSerum', 'RespiratoryRate', 'PaO2FiO2'])
        data_2 = data_2.round(decimals)
        #data_2 = data_2.astype('int64') # this truncates, hence we round before this
        #data_2ad = data_2ad.astype('int64') # this truncates, hence we round before this

        # join everything together
        #data_4 = pd.concat([data_2, data_2ad, data_2adc], axis=1)
        data_4 = pd.concat([data_2, orgdataadditional], axis=1)

        # add id and imp and append to main dataset
        data_4.insert(0, '.id', range(0, len(data_4)))
        data_4.insert(0, '.imp', n)
        if (debug):
            data_4.to_csv(fullSavePath + "decoded_" + suffix+ str(n) + ".csv", index=False)
        print(fullSavePath + "decoded_" + suffix + str(n) + ".csv")

        orgdf1 = orgdf1.append(data_4, ignore_index=True)

    orgdf1.to_csv(fullSavePath + suffix + "_full.csv", index=False)
    print(fullSavePath + suffix + "_full.csv")


outputdatasets(da_columns_list, dataadditional, imputer, orgdf, fullSavePath, orgdataadditional=data_additional_ordered_org)


#encode
#dataimpute, di_columns_list = encodedf(data_imputation_target)
# datatimpute=datat_imputation_target
# datatimpute.to_csv(fullSavePath+"TESTDIencoded.csv", index=False)
# datatadditional, dat_columns_list = encodedf(datat_additional_ordered)
# datatadditional.to_csv(fullSavePath+"TESTDAencoded.csv", index=False)
#
# #scale
# datatimpute, ditscaler = minmaxer(datatimpute)
# datatimpute.to_csv(fullSavePath+"TESTDIscaled.csv", index=False)
# datatadditional, datscaler = minmaxer(datatadditional)
# datatadditional.to_csv(fullSavePath+"TESTDAscaled.csv", index=False)

# Helper method to allow for imputed dataset to be hotswapped.MIDAS is not
# designed with such a function in mind, but this should allow for more flexible workflows.

#clear post event data
datatestadditionalorg  = datatestadditional.copy()
datatestadditional[postevent] = np.nan

print("changing target")
imputer.change_imputation_target(datatestimpute, datatestadditional)

if (doTargetTrain):
    print("training on new target")
    startTime = dt.now()
    imputer.train_model(training_epochs=epochs, verbosity_ival=1, verbose=doVerbose)
    endTime = dt.now()
    print("Runtime for training " + datasetName + ": ", endTime - startTime)

print("generating samples for new target")
# Generate the 'm' number of datasets
imputer.batch_generate_samples(m=m)

#imputer.generate_samples(m=m)

#outputdatasets(da_columns_list, datatestadditional, imputer, orgdft, fullSavePath, suffix='TEST')
outputdatasets(da_columns_list, datatestadditionalorg, imputer, orgdft, fullSavePath, suffix='TEST', orgdataadditional=datat_additional_ordered_org)


# TODO: do we NAN out post events
# can we exclude them