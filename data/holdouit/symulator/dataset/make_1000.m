clc
clear
close

all_signals=zeros(0, 1000);
currentFolder = pwd;

arrythmia=["Atrial_fibrillation/","Bradycardia/","Tachycardia/"];
for arr = arrythmia %for each type of arrythmia
    arr
    datafolder = fullfile(currentFolder, arr);
    folder_path = dir(datafolder);

    

    for i =3:length(folder_path) %for each folder
        file_list=dir(fullfile(datafolder, folder_path(i).name));

        for j = 3:length(file_list) %for each file

            % open file
            temp = fullfile(datafolder,folder_path(i).name, file_list(j).name);
            file = load(temp);
            signal=file.signals.PPG;

            for k=1:min(size(signal)) %for each signal

                current_signal=signal(1,:);
                bandpass_data = bandpass(signal',[0.5,40],125);
                resampled_signal = resample(bandpass_data, 100, 500);
                resampled_signal=normalize(resampled_signal,"range");

                resampled_data = resampled_signal(1:floor(length(resampled_signal)/1000)*1000); % Ucięcie do najbliższej wielokrotności 1000
                reshaped_data = reshape(resampled_data, 1000, []); % Przekształcenie
                reshaped_data=reshaped_data';
                all_signals=cat(1,reshaped_data,all_signals);
            end
        end
    end
end
test = ones(max(size(all_signals)),1);
all_signals=cat(2,test,all_signals);
writematrix(all_signals,"symulator_af.csv")