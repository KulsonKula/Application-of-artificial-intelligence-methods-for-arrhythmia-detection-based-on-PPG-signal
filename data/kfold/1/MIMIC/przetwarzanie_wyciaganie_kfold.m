load("mimic_perform_af_data")
af_ppg = [data.ppg];
total_af = 1:length(af_ppg); % 1:19

load("mimic_perform_non_af_data")
nonaf_ppg = [data.ppg];
total_nonaf = 1:length(nonaf_ppg); % 1:16

% Foldy — indeksy z MATLAB (1-based)
folds = {
    [5, 12, 3, 18], [8, 1, 14];   % fold 1
    [2, 9, 17, 14], [10, 5, 13];  % fold 2
    [7, 1, 16, 11], [6, 12, 15];  % fold 3
    [8, 4, 13, 6],  [3, 11, 9];   % fold 4
    [10, 15, 2, 19],[7, 4, 2];    % fold 5
};

for f = 1:5
    af_indices = folds{f,1};
    nonaf_indices = folds{f,2};

    % === fold_N.csv ===
    fold_data = [];

    for idx = af_indices
        signal = af_ppg(idx).v;
        signal(~isfinite(signal)) = 0;
        signal = bandpass(signal',[0.5,40],125);
        resampled = resample(signal, 100, 125);

        % Ucięcie do najbliższej wielokrotności 1000
        resampled = resampled(1:floor(length(resampled)/1000)*1000); 
        
        % Podzielenie na okna po 1000 próbek
        reshaped_data = reshape(resampled, 1000, []); 
        
        % Normalizacja dla każdego okna
        normalized = normalize(reshaped_data, "range");

        % Dodanie etykiety 1 dla AF (każde okno)
        fold_data = [fold_data; [ones(size(normalized, 2), 1), normalized(:,:)']];
    end

    for idx = nonaf_indices
        signal = nonaf_ppg(idx).v;
        signal(~isfinite(signal)) = 0;
        signal = bandpass(signal',[0.5,40],125);
        resampled = resample(signal, 100, 125);

        % Ucięcie do najbliższej wielokrotności 1000
        resampled = resampled(1:floor(length(resampled)/1000)*1000); 
        
        % Podzielenie na okna po 1000 próbek
        reshaped_data = reshape(resampled, 1000, []); 
        
        % Normalizacja dla każdego okna
        normalized = normalize(reshaped_data, "range");

        % Dodanie etykiety 0 dla non-AF (każde okno)
        fold_data = [fold_data; [zeros(size(normalized, 2), 1), normalized(:,:)']];
    end

    % Zapis do pliku fold_N.csv
    writematrix(fold_data, sprintf('fold_%d_test.csv', f));

    % === fold_N_rest.csv ===
    af_rest = setdiff(total_af, af_indices);
    nonaf_rest = setdiff(total_nonaf, nonaf_indices);

    fold_rest_data = [];

    for idx = af_rest
        signal = af_ppg(idx).v;
        resampled = resample(signal, 100, 125);

        % Ucięcie do najbliższej wielokrotności 1000
        resampled = resampled(1:floor(length(resampled)/1000)*1000); 
        
        % Podzielenie na okna po 1000 próbek
        reshaped_data = reshape(resampled, 1000, []); 
        
        % Normalizacja dla każdego okna
        normalized = normalize(reshaped_data, "range");

        % Dodanie etykiety 1 dla AF (każde okno)
        fold_rest_data = [fold_rest_data; [ones(size(normalized, 2), 1), normalized(:,:)']];
    end

    for idx = nonaf_rest
        signal = nonaf_ppg(idx).v;
        resampled = resample(signal, 100, 125);

        % Ucięcie do najbliższej wielokrotności 1000
        resampled = resampled(1:floor(length(resampled)/1000)*1000); 
        
        % Podzielenie na okna po 1000 próbek
        reshaped_data = reshape(resampled, 1000, []); 
        
        % Normalizacja dla każdego okna
        normalized = normalize(reshaped_data, "range");

        % Dodanie etykiety 0 dla non-AF (każde okno)
        fold_rest_data = [fold_rest_data; [zeros(size(normalized, 2), 1), normalized(:,:)']];
    end

    % Zapis do pliku fold_N_rest.csv
    writematrix(fold_rest_data, sprintf('fold_%d_train.csv', f));
end
