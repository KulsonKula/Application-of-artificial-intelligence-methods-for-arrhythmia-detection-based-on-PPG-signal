clear
close
clc

% Ścieżka wejściowa z plikami MAT
input_folder = 'training/tachycardia/';
output_af_folder = 'output_af';
output_nonaf_folder = 'output_nonaf';

mkdir(output_af_folder);
mkdir(output_nonaf_folder);

files = dir(fullfile(input_folder, '*.mat'));

global keyPressed
f = figure;
set(f, 'KeyPressFcn', @onKey);

for k = 1:length(files)
    % Załaduj plik
    file_path = fullfile(files(k).folder, files(k).name);
    data = load(file_path);


    % Pobierz trzeci sygnał i przeskaluj
    val = data.val(3, :);
    bandpass_data = bandpass(val,[0.5,40],250);
    current_val = resample(bandpass_data, 100, 250);
    reshaped_data=normalize(current_val,"range");
    % == 1. Pokazanie pełnego sygnału ==
    clf;
    plot(reshaped_data);
    remaining = length(files) - k + 1;
    fprintf('Przetwarzanie pliku %d z %d. Pozostało %d plików.\n', k, length(files), remaining);

    title(sprintf('Plik: %s\nWciśnij ↑ aby kontynuować do segmentacji', files(k).name));
    xlabel('Próbki');
    ylabel('Amplituda');

    % Czekaj na ↑ (strzałka w górę)
    keyPressed = '';
    while ~strcmp(keyPressed, 'uparrow')
        pause(0.1);
    end

    % == 2. Segmentacja i klasyfikacja ==
    af = [];
    nonaf = [];
    num_blocks = ceil(length(reshaped_data) / 1000);

    for i = 1:num_blocks
        clf;

        start_idx = (i - 1) * 1000 + 1;
        end_idx = min(i * 1000, length(reshaped_data));
        segment = reshaped_data(start_idx:end_idx);

        if length(segment) < 1000
            segment(end+1:1000) = 0;
        end

        plot(segment);
        title(sprintf(['Plik: %s\nBlok %d/%d\n← = nonaf | → = af'], ...
            files(k).name, i, num_blocks));
        xlabel('Próbki');
        ylabel('Amplituda');

        % Czekaj na ← lub →
        keyPressed = '';
        while ~ismember(keyPressed, {'leftarrow', 'rightarrow'})
            pause(0.1);
        end

        switch keyPressed
            case 'leftarrow'
                nonaf = [nonaf; segment];
            case 'rightarrow'
                af = [af; segment];
        end
    end

    % Zapisz bloki po przetworzeniu pliku
    [~, name, ~] = fileparts(files(k).name);
    writematrix(af, fullfile(output_af_folder, [name, '.csv']));
    writematrix(nonaf, fullfile(output_nonaf_folder, [name, '.csv']));
end

close(f);

% Obsługa klawiszy
function onKey(~, event)
    global keyPressed
    keyPressed = event.Key;
end