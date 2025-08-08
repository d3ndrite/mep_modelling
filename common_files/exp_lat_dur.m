
function [durn_exp,peakdiff_durn_exp,end_idx_exp]=exp_lat_dur(mean_data, subj)

mep_exp=mean_data;
mep_new=NaN*ones(size(mep_exp));

[fp_loc] = find(mep_exp==max(mep_exp)); 
[sp_loc] = find(mep_exp==min(mep_exp)); 
mep_new (fp_loc:sp_loc)=mep_exp(fp_loc:sp_loc);

% figure(subj)
% plot(mep_exp)
% hold on
% xline(fp_loc)
% xline(sp_loc)

diff_mep=smooth(diff(mep_exp));

% hold on
% plot(diff_mep,'r')

threshold=6*(std((diff_mep(end-50:end))));
indices_keep = find(diff_mep>threshold);

mep_new(indices_keep)=mep_exp(indices_keep);


mep_new(249:end)=NaN;
mep_new(1:50)=NaN;

% mep(351)=NaN;
% plot(mep_new,'*m');

mep_start(subj) = find(~isnan(mep_new(1:fp_loc)),1,'first');
start_idx_exp=mep_start(subj);

lastnans=find(isnan(mep_new(sp_loc:end)));

mep_end(subj)=sp_loc+lastnans(1);

if subj==16
    lastvals=find(~isnan(mep_new(end:-1:sp_loc)));
    mep_end(subj)=351-lastvals(1);
end

end_idx_exp = mep_end(subj);

% xline(mep_start(subj),'g')
durn_exp=(end_idx_exp-start_idx_exp)*0.1;
peakdiff_durn_exp=sp_loc-fp_loc;
% xline(mep_end(subj),'g')
% title('Subject :1')
% xlabel('ms');
% ylabel('mV');

