clc
clear
close

signals=readmatrix("Atrial_fibrillation\data_all_croped_croped.csv");

% signals=df(:,1:91596);

[W,K]=size(signals)

del=mod(K-1,3)
cropped=signals(:,1:K-del);



% Przyjmujemy, że Twoja tabela nazywa się "T".
% Zakładamy, że T jest macierzą (jeśli masz tabelę jako obiekt, użyj table2array).

% Pobranie wierszy od 5 do końca
T_sub = cropped(5:end, :);

% Zachowanie pierwszych 4 kolumn
firstFourCols = T_sub(:, 1:4);

% Podzielenie pozostałych kolumn na 3 części
numCols = size(T_sub, 2);
remainingCols = T_sub(:, 5:end);

% Sprawdzenie, czy liczba kolumn jest podzielna przez 3
if mod(size(remainingCols, 2), 3) ~= 0
    error('Liczba kolumn do podziału nie jest wielokrotnością 3.');
end

% Wyznaczenie liczby kolumn na część
partSize = size(remainingCols, 2) / 3;

% Wyodrębnienie części
part1 = [firstFourCols, remainingCols(:, 1:partSize)];
part2 = [firstFourCols, remainingCols(:, partSize+1:2*partSize)];
part3 = [firstFourCols, remainingCols(:, 2*partSize+1:end)];

% Przyjmujemy, że part1, part2, i part3 już istnieją zgodnie z wcześniejszym kodem.

% Połączenie wszystkich części w jedną tabelę
combined = [part1; part2; part3];

% Dodanie nowego wiersza z etykietami na początku
labels = ["arrytmia", "rhythm", "type", "set", 1:(size(combined, 2) - 4)];
combined_with_labels = [labels; combined];

% Zapis do pliku CSV
writematrix(combined_with_labels, 'data_all_croped_croped.csv');



% labels=["arrytmia" "rhythm" "type" "set" 1:(length(signals)-4)];
% signals=[labels; signals(2:end,:)];
% writematrix(signals,'data_all_croped.csv_changed')