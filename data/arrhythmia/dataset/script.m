%% SETUP
clc;
clear;
close;

signals=[];
labels_type=[0;1;2;3;4];
labels_arrytmia=[1;1;1;1;1];
labels_rhythm=[1;1;1;1;1];

file_num=0;
tic
%% CODE

currentFolder = pwd;
datafolder = fullfile(currentFolder, 'Tachycardia');
folder_path = dir(datafolder);


for i =3:length(folder_path)
    file_list=dir(fullfile(datafolder, folder_path(i).name));
    for j = 3:length(file_list)

        % open file
        temp = fullfile(datafolder,folder_path(i).name, file_list(j).name);
        file = load(temp);
        signal_file=file.signals.PPG;
        
        signal_file=[labels_arrytmia labels_rhythm labels_type str2double(folder_path(i).name)*ones(5,1) signal_file];

        % resize
        if size(signals, 2) > size(signal_file, 2)
            signal_file(:, end+1:size(signals, 2)) = 0;
        elseif size(signals, 2) < size(signal_file, 2)
            signals(:, end+1:size(signal_file, 2)) = 0;
        end

        % concat
        signals=[signals; signal_file];

        % safety
        file_num=file_num+1;
        disp("file:" + file_num);
    end

end

%% CSV MAKE
labels=["arrytmia" "rhythm" "type" "set" 1:(length(signals)-4)];
signals=[labels; signals(2:end,:)];
writematrix(signals,'data_all.csv')
toc