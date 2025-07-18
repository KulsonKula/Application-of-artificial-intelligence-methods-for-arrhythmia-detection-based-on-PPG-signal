clc
clear
close

fold="4";
data="train";
% Ścieżka do folderu z plikami CSV
folderPath = "foldy/fold_"+fold+"/"+data+"/af"'; 
files = dir(fullfile(folderPath, '*.csv'));

% Inicjalizacja pustej tabeli
allData_af = [];

for i = 1:length(files)
    filePath = fullfile(folderPath, files(i).name);
    try
        % Wczytaj dane bez nagłówka (pomijając pierwszy wiersz)
        T = readmatrix(filePath, 'NumHeaderLines', 1);
    catch
        warning('Nie udało się wczytać pliku: %s', files(i).name);
        continue;
    end

    % Dodaj kolumnę '1' jako pierwszą (arrythmia)
    T = [ones(size(T,1),1), T];

    % Sklej do wspólnej macierzy
    allData_af = [allData_af; T];

    % Informacja co 10 plik
    if mod(i, 10) == 0
        fprintf('Przetworzono %d z %d plików...\n', i, length(files));
    end
end


% Ścieżka do folderu z plikami CSV
folderPath = "foldy/fold_"+fold+"/"+data+"/nonaf"';
files = dir(fullfile(folderPath, '*.csv'));

% Inicjalizacja pustej tabeli
allData_nonaf = [];

for i = 1:length(files)
    filePath = fullfile(folderPath, files(i).name);
    try
        % Wczytaj dane bez nagłówka (pomijając pierwszy wiersz)
        T = readmatrix(filePath, 'NumHeaderLines', 1);
    catch
        warning('Nie udało się wczytać pliku: %s', files(i).name);
        continue;
    end

    % Dodaj kolumnę '1' jako pierwszą (arrythmia)
    T = [zeros(size(T,1),1), T];

    % Sklej do wspólnej macierzy
    allData_nonaf = [allData_nonaf; T];

    % Informacja co 10 plik
    if mod(i, 10) == 0
        fprintf('Przetworzono %d z %d plików...\n', i, length(files));
    end
end


allData=[allData_af;allData_nonaf];
% Zapis do nowego pliku CSV
writematrix(allData, "fold_"+fold+"_"+data+"_psynet.csv");

fprintf('Scalanie zakończone. Zapisano %d wierszy do "scalony_plik.csv"\n', height(allData));