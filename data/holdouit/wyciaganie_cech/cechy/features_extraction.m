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

csv=extract_and_save(test_dataset,"dataset_test.csv");
csv=extract_and_save(train_dataset,"dataset_train.csv");
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
    featureMatrix(i, 7) = sum(signal.^2); % Energy

    featureMatrix(i, 6) = mad(signal, 1); % Mean Absolute Deviation
    
    featureMatrix(i, 8) = skewness(signal); % Asymmetry
    featureMatrix(i, 9) = wentropy(signal, 'shannon'); % Shannon Entropy
    featureMatrix(i, 10) = featureMatrix(i, 3) / featureMatrix(i, 1); % Coefficient of Variation

    % Normalizacja cech związanych z różnicami
    differences = diff(signal);
    featureMatrix(i, 11) = mean(differences); % Mean
    featureMatrix(i, 12) = median(differences); % Median
    featureMatrix(i, 13) = std(differences); % Standard Deviation
    featureMatrix(i, 14) = var(differences); % Variance
    featureMatrix(i, 15) = iqr(differences); % Interquartile Range
    featureMatrix(i, 7) = sum(differences.^2); % Energy

    featureMatrix(i, 16) = mean(abs(differences)); % Average of the absolute value of the differences
    featureMatrix(i, 17) = 100 * sum(differences > 0) / (length(signal) - 1); % Percentage of Positive Differences
    featureMatrix(i, 18) = sqrt(mean(differences.^2)); % RMSSD
    featureMatrix(i, 19) = mean(abs(differences)) / featureMatrix(i, 1); % Normalized Absolute Deviation
    featureMatrix(i, 20) = sum(abs(differences)) / sum(abs(signal)); % Normalized Absolute Difference

    % --- Cechy z domeny częstotliwości ---
    [pxx, f] = periodogram(signal); % Widmo sygnału
    featureMatrix(i, 21) = mean(pxx); % Mean
    featureMatrix(i, 22) = median(pxx); % Median
    featureMatrix(i, 23) = std(pxx); % Standard Deviation
    featureMatrix(i, 24) = var(pxx); % Variance
    featureMatrix(i, 25) = iqr(pxx); % Interquartile Range

    featureMatrix(i, 26) = f(pxx == max(pxx)); % Maximal Spectral Peak
    featureMatrix(i, 27) = kurtosis(pxx); % Kurtosis of Spectrum
    featureMatrix(i, 28) = sum(pxx); % Total Spectral Energy
    featureMatrix(i, 29) = sum(pxx > mean(pxx)) / length(pxx); % Fraction of High Peaks

    % --- Zależności czasowo-częstotliwościowe ---
    wt = cwt(signal, 'amor'); % Continuous Wavelet Transform (Morlet Wavelet)
    featureMatrix(i, 30) = mean(abs(wt), 'all');        % Mean Wavelet Coefficient Magnitude
    featureMatrix(i, 31) = median(abs(wt), 'all');       % Median Wavelet Coefficient
    featureMatrix(i, 32) = std(abs(wt), 0, 'all');       % Std Wavelet Coefficient Magnitude
    featureMatrix(i, 33) = var(abs(wt), 0, 'all');       % Variance Wavelet Coefficient Magnitude
    featureMatrix(i, 34) = iqr(abs(wt), 'all');          % IQR Wavelet Coefficient

    featureMatrix(i, 35) = sum(abs(wt).^2, 'all');       % Wavelet Energy
    featureMatrix(i, 36) = max(abs(wt), [], 'all');      % Max Wavelet Coefficient
    featureMatrix(i, 37) = entropy(abs(wt), 'shannon'); % Wavelet Shannon Entropy



    disp(i)

end
end



