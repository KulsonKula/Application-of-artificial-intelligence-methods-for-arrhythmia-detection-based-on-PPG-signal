clc
clear
close all

mimic_af=readmatrix("../mimic_af.csv");
mimic_nonaf=readmatrix("../mimic_nonaf.csv");
symulator=readmatrix("../symulator_af.csv");
repo=readmatrix("../repo.csv");

train_dataset=[symulator;repo];
test_dataset=[mimic_nonaf;mimic_af];

train_dataset=rmmissing(train_dataset);
test_dataset=rmmissing(test_dataset);

writematrix(test_dataset,"no_features_dataset_test.csv");
writematrix(train_dataset,"no_features_dataset_train.csv");

