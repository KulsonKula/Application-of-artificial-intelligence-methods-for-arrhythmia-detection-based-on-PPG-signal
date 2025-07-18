clc
clear
close all

mimic_train=readmatrix("MIMIC/fold_5_train.csv");
mimic_test=readmatrix("MIMIC/fold_5_test.csv");

repo_train=readmatrix("repo/train_fold_5.csv");
repo_test=readmatrix("repo/test_fold_5.csv");

symulator_train=readmatrix("symulator/train/symulator_af.csv");

psynet_train=readmatrix("psynet/fold_4_train_psynet.csv");
psynet_test=readmatrix("psynet/fold_4_test_psynet.csv");

train_dataset=[symulator_train;repo_train;mimic_train;psynet_train];
test_dataset=[repo_test;mimic_test;psynet_test];

train_dataset=rmmissing(train_dataset);
test_dataset=rmmissing(test_dataset);

writematrix(train_dataset, "fold_5_train_no_features.csv");
writematrix(test_dataset, "fold_5_test_no_features.csv");

csv=extract_and_save(test_dataset,"fold_5_test.csv");
csv=extract_and_save(train_dataset,"fold_5_train.csv");
function csv=extract_and_save(signals,name)
signal=signals(:,2:end);
labels=signals(:,1);

tic
features=extractFeatures(signal(:,5:end));
toc

label_features=[labels,features];

csv_top=[
    "arrytmia","mean","median","std","variance","iqr","maximum","minimum","mean_abs_diff","percentage_positive_differences","rmssd","mean_absolute_deviation","energy","skewness","shannon_entropy","maximal_spectral_peak","mean_spectrum","std_spectrum","kurtosis_spectrum","total_spectral_energy","fraction_high_peaks","mean_wavelet_coefficient_magnitude","std_wavelet_coefficient_magnitude","wavelet_energy","coefficient_of_variation","max_wavelet_coefficient","median_wavelet_coefficient","wavelet_shannon_entropy","normalized_absolute_deviation","normalized_absolute_difference","normalized_rmssd"
    ];

csv=[csv_top;label_features];

writematrix(csv, name);
end


function featureMatrix = extractFeatures(data)

% Liczba rekordów
numRecords = size(data, 1);

% Inicjalizacja macierzy wynikowej
featureMatrix = zeros(numRecords, 30);

for i = 1:numRecords
    signal = data(i, :); % Pobranie sygnału dla danego rekordu

    % --- Cechy z domeny czasu ---
    featureMatrix(i, 1) = mean(signal); % Mean
    featureMatrix(i, 2) = median(signal); % Median
    featureMatrix(i, 3) = std(signal); % Standard Deviation
    featureMatrix(i, 4) = var(signal); % Variance
    featureMatrix(i, 5) = iqr(signal); % Interquartile Range
    featureMatrix(i, 6) = max(signal); % Maximum
    featureMatrix(i, 7) = min(signal); % Minimum
    featureMatrix(i, 8) = mean(abs(diff(signal))); % Average of the absolute value of the differences
    featureMatrix(i, 9) = 100 * sum(diff(signal) > 0) / (length(signal) - 1); % Percentage of Positive Differences
    featureMatrix(i, 10) = sqrt(mean(diff(signal).^2)); % RMSSD
    featureMatrix(i, 11) = mad(signal, 1); % Mean Absolute Deviation
    featureMatrix(i, 12) = sum(signal.^2); % Energy
    featureMatrix(i, 13) = skewness(signal); % Asymmetry

    % --- Entropia ---
    featureMatrix(i, 14) = wentropy(signal, 'shannon'); % Shannon Entropy

    % --- Cechy z domeny częstotliwości ---
    [pxx, f] = periodogram(signal); % Widmo sygnału
    featureMatrix(i, 15) = f(pxx == max(pxx)); % Maximal Spectral Peak
    featureMatrix(i, 16) = mean(pxx); % Mean of Spectrum
    featureMatrix(i, 17) = std(pxx); % Standard Deviation of Spectrum
    featureMatrix(i, 18) = kurtosis(pxx); % Kurtosis of Spectrum
    featureMatrix(i, 19) = sum(pxx); % Total Spectral Energy
    featureMatrix(i, 20) = sum(pxx > mean(pxx)) / length(pxx); % Fraction of High Peaks

    % --- Zależności czasowo-częstotliwościowe ---
    wt = cwt(signal, 'amor'); % Continuous Wavelet Transform (Morlet Wavelet)
    featureMatrix(i, 21) = mean(abs(wt), 'all'); % Mean Wavelet Coefficient Magnitude
    featureMatrix(i, 22) = std(abs(wt), 0, 'all'); % Std Wavelet Coefficient Magnitude
    featureMatrix(i, 23) = sum(abs(wt).^2, 'all'); % Wavelet Energy

    % --- Cechy dodatkowe ---
    featureMatrix(i, 24) = featureMatrix(i, 1) / featureMatrix(i, 3); % Coefficient of Variation
    featureMatrix(i, 25) = max(abs(wt), [], 'all'); % Max Wavelet Coefficient
    featureMatrix(i, 26) = median(abs(wt), 'all'); % Median Wavelet Coefficient
    featureMatrix(i, 27) = wentropy(abs(wt), 'shannon'); % Wavelet Shannon Entropy

    % Normalizacja cech związanych z różnicami
    differences = diff(signal);
    featureMatrix(i, 28) = mean(abs(differences)) / featureMatrix(i, 1); % Normalized Absolute Deviation
    featureMatrix(i, 29) = sum(abs(differences)) / sum(abs(signal)); % Normalized Absolute Difference
    featureMatrix(i, 30) = sqrt(mean(differences.^2)) / sqrt(mean(signal.^2)); % Normalized RMSSD

    if mod(i,1000)==0
        disp(i)
    end
end
end



