function [diff_lat, lat_exp_idx, lat_sim_idx] = lat_mep (exp_data, epoched_sim_mep, sim_mep)

% diff_mep_exp = smooth(diff(exp_data)); 
% threshold_exp = 3*std(diff_mep_exp(1:50));
% lat_exp_idx = find(diff_mep_exp>threshold_exp, 1, "first");
% lat_exp = (150+lat_exp_idx)*(0.1);
% Logic2: 
[~,idxmep_exp]=findpeaks(exp_data,"NPeaks",1,MinPeakHeight=0.2);
threshold_exp = std(exp_data(1:50));
idx_start_temp_exp=find(exp_data(idxmep_exp:-1:1)<threshold_exp,1,'first');
idx_start_exp=idxmep_exp-idx_start_temp_exp;
lat_exp_idx = idx_start_exp;
% logic1.5:
% diff_mep_exp = smooth(diff(exp_data)); 
% threshold_exp = 6*std(diff_mep_exp(1:50));
% [~,idxmep_exp]=findpeaks(exp_data,"NPeaks",1,MinPeakHeight=0.2);
% idx_start_temp_exp=find(diff_mep_exp(idxmep_exp:-1:1)<threshold_exp,1,'first');
% idx_start_exp=idx_start_temp_exp; 
% lat_exp_idx = idx_start_exp;
% hold on
% xline(idx_start-1);

% lat_exp = (150+lat_exp_idx)*(0.1);
lat_exp = (lat_exp_idx)*(0.1);

% sim_mep=epoched_sim_array;

[~,idxmep]=findpeaks(sim_mep,"NPeaks",1,MinPeakHeight=0.2); %!! 0.2 -> 0.1
threshold_sim = mad(epoched_sim_mep(1:300));
idx_start_temp=find(sim_mep(idxmep:-1:1)<threshold_sim,1,'first');
idx_start=idxmep-idx_start_temp;
% hold on
% xline(idx_start-1);
lat_sim_idx = idx_start;
% lat_sim = (150+lat_sim_idx)*(0.1);
lat_sim = (lat_sim_idx)*(0.1);

% diff_mep_sim = smooth(diff(sim_mep)); 
% threshold_sim = 3*std(diff_mep_sim(1:50));
% lat_sim_idx = find(diff_mep_sim>threshold_sim, 1, "first");
% lat_sim = (150+lat_sim_idx)*(0.1);

difference = lat_exp - lat_sim;

diff_lat = abs(difference);
end

