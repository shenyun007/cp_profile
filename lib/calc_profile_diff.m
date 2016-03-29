function [mean_diff_tempv,wnd_cmp,sum_diff_obs]=calc_profile_diff(target_datelist,sr_dt_list,snd_dt_list)
%Joshua Soderholm, March 2016
%Climate Research Group, University of Queensland

%what: Calculates the average difference between  SODAR/RASS and sounding
%profiles for vtemp and uwind

%load config
load('etc/config.mat');

%load processed mat
load(cp_data_ffn)

%init loop
intp_h_vec = [min_h:bin_h:max_h]';
empty_mat  = nan(length(intp_h_vec),length(target_datelist));

diff_tempv_mat = empty_mat;
sr_uwnd_mat    = empty_mat;
sr_vwnd_mat    = empty_mat;
snd_uwnd_mat   = empty_mat;
snd_vwnd_mat   = empty_mat;

for i=1:length(target_datelist)
    %update user
    display(['Processing day: ',num2str(i),' of ', num2str(length(target_datelist))]);
    
    %find nearest index for snd data
    target_dt                 = addtodate(target_datelist(i),mean_time,'hour');
    [snd_dt_diff,snd_ind]     = min(abs(snd_dt_list-target_dt));
    %skip if snd data close to required time cannot be found
    if snd_dt_diff*24>max_time_diff
        display('skipping, snd time different too large')
        continue
    end
    %extract snd data
    snd_tempv  = snd_dataset.(['data',num2str(snd_ind)]).tempv;
    snd_wspd   = snd_dataset.(['data',num2str(snd_ind)]).wspd;
    snd_wdir   = snd_dataset.(['data',num2str(snd_ind)]).wdir;
    snd_site_h = snd_dataset.(['data',num2str(snd_ind)]).site_h;
    snd_h      = snd_dataset.(['data',num2str(snd_ind)]).h + snd_site_h;
    
    %calc sounding u winds
    snd_wnd_nan_mask           = isnan(snd_wdir) | isnan(snd_wspd);
    snd_wdir(snd_wnd_nan_mask) = 0;
    snd_wspd(snd_wnd_nan_mask) = 0;
    [snd_uwnd,snd_vwnd] = compass2cart(snd_wdir,snd_wspd);
    snd_uwnd(snd_wnd_nan_mask) = nan;
    snd_vwnd(snd_wnd_nan_mask) = nan;
    
    %calc mean wind speed in direction of rass
    sr_target_dt = addtodate(target_dt,sr_snd_hour_diff,'hour'); %assume mean sea breeze speed of 25km/h or so (can improve)
    [sr_dt_diff,sr_ind]  = min(abs(sr_dt_list-sr_target_dt));

    if sr_dt_diff*24>max_time_diff
        display('skipping, sr time different too large')
        continue
    end
    
    %extract profiles
    sr_tempv  = sr_dataset.(['data',num2str(sr_ind)]).tempv;
    sr_uwnd   = -sr_dataset.(['data',num2str(sr_ind)]).u; %keep as barb direction rather than vector
    sr_vwnd   = -sr_dataset.(['data',num2str(sr_ind)]).v; %keep as barb direction rather than vector
    sr_site_h = sr_dataset.(['data',num2str(sr_ind)]).site_h;
    sr_h      = sr_dataset.(['data',num2str(sr_ind)]).h + sr_site_h;

    %% interpolate onto same vertical grid

    %create nan mask
    sr_tempv_mask   = isnan(sr_tempv);
    sr_wnd_mask     = isnan(sr_uwnd) | isnan(sr_vwnd);
    snd_tempv_mask  = isnan(snd_tempv);
    snd_wnd_mask    = isnan(snd_uwnd) | isnan(snd_vwnd);
    

    %skip if no sr data exists
    if sum(~sr_tempv_mask)<2
        display('missing sr data')
        continue
    end
    
    %interpolate onto standard height vector
    intp_sr_tempv  = interp1(sr_h(~sr_tempv_mask),sr_tempv(~sr_tempv_mask),intp_h_vec,'linear',nan);
    intp_sr_uwnd   = interp1(sr_h(~sr_wnd_mask),sr_uwnd(~sr_wnd_mask),intp_h_vec,'linear',nan);
    intp_sr_vwnd   = interp1(sr_h(~sr_wnd_mask),sr_vwnd(~sr_wnd_mask),intp_h_vec,'linear',nan);
    intp_snd_tempv = interp1(snd_h(~snd_tempv_mask),snd_tempv(~snd_tempv_mask),intp_h_vec,'linear',nan);
    intp_snd_uwnd = interp1(snd_h(~snd_wnd_mask),snd_uwnd(~snd_wnd_mask),intp_h_vec,'linear',nan);
    intp_snd_vwnd = interp1(snd_h(~snd_wnd_mask),snd_vwnd(~snd_wnd_mask),intp_h_vec,'linear',nan);
    
    %calculate difference
    diff_tempv_mat(:,i) = intp_sr_tempv-intp_snd_tempv;
    sr_uwnd_mat(:,i)    = intp_sr_uwnd;
    sr_vwnd_mat(:,i)    = intp_sr_vwnd;
    snd_uwnd_mat(:,i)   = intp_snd_uwnd;
    snd_vwnd_mat(:,i)   = intp_snd_vwnd;
    
end

%calc mean diff profiles
mean_diff_tempv = nanmean(diff_tempv_mat,2);
%export wind data struct
wnd_cmp = struct;
wnd_cmp.sr_uwnd  = nanmean(sr_uwnd_mat,2);
wnd_cmp.sr_vwnd  = nanmean(sr_vwnd_mat,2);
wnd_cmp.snd_uwnd = nanmean(snd_uwnd_mat,2);
wnd_cmp.snd_vwnd = nanmean(snd_vwnd_mat,2);

sum_diff_obs    = sum(~isnan(diff_tempv_mat),2);