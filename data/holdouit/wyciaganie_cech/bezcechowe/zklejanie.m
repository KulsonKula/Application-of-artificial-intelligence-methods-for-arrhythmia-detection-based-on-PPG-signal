clc
clear
close all

mimic_af=readmatrix("../mimic_af.csv");
mimic_nonaf=readmatrix("../mimic_nonaf.csv");
symulator=readmatrix("../symulator_af.csv");
repo=readmatrix("../repo.csv");
psynet_af=readmatrix("../psynet_af.csv");
psynet_nonaf=readmatrix("../psynet_nonaf.csv");

train_dataset=[symulator;repo;mimic_nonaf;mimic_af];
test_dataset=[psynet_af;psynet_nonaf];

train_dataset=rmmissing(train_dataset);
test_dataset=rmmissing(test_dataset);

writematrix(test_dataset,"no_features_dataset_test.csv");
writematrix(train_dataset,"no_features_dataset_train.csv");

