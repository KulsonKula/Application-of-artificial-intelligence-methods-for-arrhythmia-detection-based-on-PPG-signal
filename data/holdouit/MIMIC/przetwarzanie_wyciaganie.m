clc
clear
close
%%
load("mimic_perform_af_data")
ppg=[data.ppg];
final_af= zeros(0, 1000);
for i=1:1:19
    signal_struct=ppg(i);
    signal=signal_struct.v;
    signal(~isfinite(signal)) = 0;
    bandpass_data = bandpass(signal,[0.5,40],125);
    resampled_data = resample(bandpass_data, 100, 125);

    resampled_data = resampled_data(1:floor(length(resampled_data)/1000)*1000); % Ucięcie do najbliższej wielokrotności 1000
    reshaped_data = reshape(resampled_data, 1000, []); % Przekształcenie
    reshaped_data=normalize(reshaped_data,"range");
    reshaped_data=reshaped_data';
    final_af=cat(1,reshaped_data,final_af);
end
test = ones(max(size(final_af)),1);
final_af=cat(2,test,final_af);
writematrix(final_af,"mimic_af.csv")
%%

load("mimic_perform_non_af_data")
ppg=[data.ppg];
final_nonaf= zeros(0, 1000);
for i=1:1:16
    signal_struct=ppg(i);
    signal=signal_struct.v;
    signal(~isfinite(signal)) = 0;
    bandpass_data = bandpass(signal,[0.5,40],125);
    resampled_data = resample(bandpass_data, 100, 125);

    resampled_data = resampled_data(1:floor(length(resampled_data)/1000)*1000); % Ucięcie do najbliższej wielokrotności 1000
    reshaped_data = reshape(resampled_data, 1000, []); % Przekształcenie
    reshaped_data=normalize(reshaped_data,"range");
    reshaped_data=reshaped_data';
    final_nonaf=cat(1,reshaped_data,final_nonaf);
end
test = zeros(max(size(final_nonaf)),1);
final_nonaf=cat(2,test,final_nonaf);

writematrix(final_nonaf,"mimic_nonaf.csv")