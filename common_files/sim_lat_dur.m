
function [durn,peak_diff_durn,idx_end_sim]=sim_lat_dur(epoched_sim_mep)

mep_sim=epoched_sim_mep;
mep_new=NaN*ones(size(mep_sim));

[fp_loc] = find(mep_sim==max(mep_sim)); 
[sp_loc] = find(mep_sim==min(mep_sim)); 
mep_new (fp_loc:sp_loc)=mep_sim(fp_loc:sp_loc);

% figure(12)
% plot(mep_sim)
% hold on
% xline(fp_loc)
% xline(sp_loc)

diff_mep=smooth(diff(mep_sim));

% hold on
% plot(diff_mep,'r')

threshold=6*(std((diff_mep(1:50))));
indices_keep = find(diff_mep>threshold);

mep_new(indices_keep)=mep_sim(indices_keep);


mep_new(249:end)=NaN;
mep_new(1:50)=NaN;

% mep(351)=NaN;
% plot(mep_new,'*m');

mep_start = find(~isnan(mep_new(1:fp_loc)),1,'first');
start_idx_sim=mep_start;

% lastnans=find(isnan(mep_new(sp_loc+10:end)));
% lastnans=find(~isnan(mep_new(end:-1:sp_loc)),1,'first');
% 
% % mep_end=sp_loc+lastnans(1);
% mep_end=length(mep_new)-lastnans;
% end_idx_sim = mep_end;
% % xline(mep_start,'g')
% durn=(end_idx_sim-start_idx_sim)*0.1;
peak_diff_durn=sp_loc-fp_loc;
% % xline(mep_end,'g')
% title('Subject :1')
% xlabel('ms');
% ylabel('mV');
% pause

[~,idxmep_sim]=findpeaks(-epoched_sim_mep,'NPeaks',1,"MinPeakHeight",0.2)
threshold_sim=mad(epoched_sim_mep(1:300));
[idx_end_temp_sim]=find(abs(epoched_sim_mep(idxmep_sim:1:end))<threshold_sim,1,'first');
idx_end_sim=idxmep_sim+idx_end_temp_sim;

end_idx_sim=idx_end_sim;
durn=(end_idx_sim-start_idx_sim)*0.1;

end