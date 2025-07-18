clc
clear
close

% Ścieżka do folderu z plikami CSV
folderPath = 'output_af';  % <- tutaj podaj ścieżkę
files = dir(fullfile(folderPath, '*.csv'));

% Inicjalizacja pustej tabeli
allData = [];

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
    allData = [allData; T];

    % Informacja co 10 plik
    if mod(i, 10) == 0
        fprintf('Przetworzono %d z %d plików...\n', i, length(files));
    end
end

% Zapis do nowego pliku CSV
writematrix(allData, 'fold3_train_psynet_af.csv');

fprintf('Scalanie zakończone. Zapisano %d wierszy do "scalony_plik.csv"\n', height(allData));