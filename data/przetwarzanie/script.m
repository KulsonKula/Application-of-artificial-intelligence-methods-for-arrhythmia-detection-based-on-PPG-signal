%% SETUP
clc;
clear;
close;

%% CODE
signals=[];
labels_type=[0;1;2;3;4];
labels_arrytmia=[1;1;1;1;1];

currentFolder = pwd;
newFolder = fullfile(currentFolder, 'data');
files = dir(newFolder);

for k = 3:length(files)
% open file
    temp = fullfile(newFolder, files(k).name);
    file = load(temp);
    signal_file=file.signals.PPG;
    signal_file=[labels_arrytmia labels_type signal_file];
% resize
    if size(signals, 2) > size(signal_file, 2)
        signal_file(:, end+1:size(signals, 2)) = 0;
    elseif size(signals, 2) < size(signal_file, 2)
        signals(:, end+1:size(signal_file, 2)) = 0;
    end
% concat
    signals=[signals; signal_file];
end


%% CSV MAKE
labels=["arrytmia" "type" 1:(length(signals)-2)];
signals=[labels; signals(2:end,:)];
writematrix(signals,'data_all.csv')