clc
clear
close all

mimic_train=readmatrix("MIMIC/fold_1_train.csv");
mimic_test=readmatrix("MIMIC/fold_1_test.csv");

repo_train=readmatrix("repo/train_fold_1.csv");
repo_test=readmatrix("repo/test_fold_1.csv");

symulator_train=readmatrix("symulator/train/symulator_af.csv");

psynet_train=readmatrix("psynet/fold_0_train_psynet.csv");
psynet_test=readmatrix("psynet/fold_0_test_psynet.csv");

train_dataset=[symulator_train;repo_train;mimic_train;psynet_train];
test_dataset=[repo_test;mimic_test;psynet_test];

train_dataset=rmmissing(train_dataset);
test_dataset=rmmissing(test_dataset);

% writematrix(train_dataset, "fold_1_train_no_features.csv");
% writematrix(test_dataset, "fold_1_test_no_features.csv");

csv=extract_and_save(test_dataset,"fold_1_test.csv");
csv=extract_and_save(train_dataset,"fold_1_train.csv");
function csv=extract_and_save(signals,name)
signal=signals(:,2:end);
labels=signals(:,1);

tic
features=extractFeatures(signal(:,5:end));
toc

label_features=[labels,features];

csv_top = ["arrytmia", "mean", "median", "std", "variance", "iqr", "skewness", "coefficient_of_variation", "mean_absolute_deviation", "shannon_entropy", "diff_mean", "diff_median", "diff_std", "diff_variance", "diff_iqr", "percentage_positive_differences", "rmssd", "normalized_absolute_deviation", "normalized_absolute_difference", "mean_abs_diff", "mean_spectrum", "median_spectrum", "std_spectrum", "variance_spectrum", "iqr_spectrum", "maximal_spectral_peak", "kurtosis_spectrum", "total_spectral_energy", "fraction_high_peaks"];

csv=[csv_top;label_features];

writematrix(csv, name);
end


function featureMatrix = extractFeatures(data)

% Liczba rekordów
numRecords = size(data, 1);

% Inicjalizacja macierzy wynikowej
featureMatrix = zeros(numRecords, 28);

for i = 1:numRecords
    signal = data(i, :); % Pobranie sygnału dla danego rekordu

    % --- Cechy z domeny czasu ---
    featureMatrix(i, 1) = mean(signal); % Mean
    featureMatrix(i, 2) = median(signal); % Median
    featureMatrix(i, 3) = std(signal); % Standard Deviation
    featureMatrix(i, 4) = var(signal); % Variance
    featureMatrix(i, 5) = iqr(signal); % Interquartile Range
  
    featureMatrix(i, 6) = skewness(signal); % Asymmetry
    featureMatrix(i, 7) = featureMatrix(i, 3) / featureMatrix(i, 1); % Coefficient of Variation
    featureMatrix(i, 8) = mad(signal, 1); % Mean Absolute Deviation
    featureMatrix(i, 9) = wentropy(signal, 'shannon'); % Shannon Entropy

    % Normalizacja cech związanych z różnicami
    differences = diff(signal);
    featureMatrix(i, 10) = mean(differences); % Mean
    featureMatrix(i, 11) = median(differences); % Median
    featureMatrix(i, 12) = std(differences); % Standard Deviation
    featureMatrix(i, 13) = var(differences); % Variance
    featureMatrix(i, 14) = iqr(differences); % Interquartile Range
   
    featureMatrix(i, 15) = 100 * sum(differences > 0) / (length(signal) - 1); % Percentage of Positive Differences
    featureMatrix(i, 16) = sqrt(mean(differences.^2)); % RMSSD
    featureMatrix(i, 17) = mean(abs(differences)) / featureMatrix(i, 1); % Normalized Absolute Deviation
    featureMatrix(i, 18) = sum(abs(differences)) / sum(abs(signal)); % Normalized Absolute Differenc
    featureMatrix(i, 19) = mean(abs(differences)); % Average of the absolute value of the differences
    
    % --- Cechy z domeny częstotliwości ---
    [pxx, f] = periodogram(signal); % Widmo sygnału
    featureMatrix(i, 20) = mean(pxx); % Mean
    featureMatrix(i, 21) = median(pxx); % Median
    featureMatrix(i, 22) = std(pxx); % Standard Deviation
    featureMatrix(i, 23) = var(pxx); % Variance
    featureMatrix(i, 24) = iqr(pxx); % Interquartile Range
 
    featureMatrix(i, 25) = f(pxx == max(pxx)); % Maximal Spectral Peak
    featureMatrix(i, 26) = kurtosis(pxx); % Kurtosis of Spectrum
    featureMatrix(i, 27) = sum(pxx); % Total Spectral Energy
    featureMatrix(i, 28) = sum(pxx > mean(pxx)) / length(pxx); % Fraction of High Peaks

  
    disp(i)

end
end



