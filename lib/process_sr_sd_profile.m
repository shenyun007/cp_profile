function [out,event_count]=process_sr_sd_profile(target_datelist,sr_dt_list,sd_dt_list,search_time)
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
empty_vec  = nan(length(intp_h_vec),1);

sr_vtemp_mat  = empty_mat;
sd_vtemp_mat  = empty_mat;
sr_uwnd_mat   = empty_mat;
sr_vwnd_mat   = empty_mat;
sd_uwnd_mat   = empty_mat;
sd_vwnd_mat   = empty_mat;

event_count   = 0;

for i=1:length(target_datelist)
    %update user
    display(['Processing day: ',num2str(i),' of ', num2str(length(target_datelist))]);
    
    %find nearest index for sd data
    target_dt               = addtodate(target_datelist(i),search_time,'hour');
    [sd_dt_diff,sd_ind]     = min(abs(sd_dt_list-target_dt));
    %skip if sd data close to required time cannot be found
    if sd_dt_diff*24>sd_max_time_diff
        display('skipping, sd time different too large')
        continue
    end
    %extract sd data
    sd_dt     = sd_dt_list(sd_ind);
    sd_vtemp  = snd_dataset.(['data',num2str(sd_ind)]).tempv;
    sd_wspd   = snd_dataset.(['data',num2str(sd_ind)]).wspd;
    sd_wdir   = snd_dataset.(['data',num2str(sd_ind)]).wdir;
    sd_site_h = snd_dataset.(['data',num2str(sd_ind)]).site_h;
    sd_h      = snd_dataset.(['data',num2str(sd_ind)]).h + sd_site_h;
    
    %calc sounding u winds
    sd_wnd_nan_mask           = isnan(sd_wdir) | isnan(sd_wspd);
    sd_wdir(sd_wnd_nan_mask) = 0;
    sd_wspd(sd_wnd_nan_mask) = 0;
    [sd_uwnd,sd_vwnd] = compass2cart(sd_wdir,sd_wspd);
    sd_uwnd(sd_wnd_nan_mask) = nan;
    sd_vwnd(sd_wnd_nan_mask) = nan;
    
    %find nearest sr dataset to sounding dataset
    [sr_dt_diff,sr_ind]  = min(abs(sr_dt_list-sd_dt));

    if sr_dt_diff*24>sr_max_time_diff
        display('skipping, sr time different too large')
        continue
    end
    
    %extract profiles
    sr_vtemp  = sr_dataset.(['data',num2str(sr_ind)]).tempv_aqc;
    sr_uwnd   = -sr_dataset.(['data',num2str(sr_ind)]).u_aqc;
    sr_vwnd   = -sr_dataset.(['data',num2str(sr_ind)]).v_aqc;
    sr_site_h = sr_dataset.(['data',num2str(sr_ind)]).site_h;
    sr_h      = sr_dataset.(['data',num2str(sr_ind)]).h + sr_site_h;

    %% interpolate onto same vertical grid

    %create nan mask and mask stupid below 10 for some dodgey datapoints
    sr_vtemp_mask  = isnan(sr_vtemp);
    sd_vtemp_mask  = isnan(sd_vtemp);
    sr_wnd_mask    = isnan(sr_uwnd) | isnan(sr_vwnd);
    sd_wnd_mask    = isnan(sd_uwnd) | isnan(sd_vwnd);

    %interpolate onto standard height vector
    %skip if no data exists
    if sum(~sr_vtemp_mask)<2 || sum(~sd_vtemp_mask)<2 %
        display('missing vtemp data')
        intp_sr_vtemp = empty_vec;
        intp_sd_vtemp = empty_vec;
    else
        intp_sr_vtemp = interp1(sr_h(~sr_vtemp_mask),sr_vtemp(~sr_vtemp_mask),intp_h_vec,'linear',nan);
        intp_sd_vtemp = interp1(sd_h(~sd_vtemp_mask),sd_vtemp(~sd_vtemp_mask),intp_h_vec,'linear',nan);
    end
 
    %skip if no data exists
    if sum(~sr_wnd_mask)<2 || sum(~sd_wnd_mask)<2 %
        display('missing wspd data')
        intp_sr_uwnd = empty_vec;
        intp_sd_uwnd = empty_vec;
        intp_sr_vwnd = empty_vec;
        intp_sd_vwnd = empty_vec;
    else
        intp_sr_uwnd  = interp1(sr_h(~sr_wnd_mask),sr_uwnd(~sr_wnd_mask),intp_h_vec,'linear',nan);
        intp_sd_uwnd  = interp1(sd_h(~sd_wnd_mask),sd_uwnd(~sd_wnd_mask),intp_h_vec,'linear',nan);
        intp_sr_vwnd  = interp1(sr_h(~sr_wnd_mask),sr_vwnd(~sr_wnd_mask),intp_h_vec,'linear',nan);
        intp_sd_vwnd  = interp1(sd_h(~sd_wnd_mask),sd_vwnd(~sd_wnd_mask),intp_h_vec,'linear',nan);
    end
    
    %apply sr rejection limits
    intp_sr_uwnd(intp_sr_uwnd>10) = nan;
    intp_sr_vwnd(intp_sr_vwnd>10) = nan;
    intp_sr_vtemp(intp_sr_vtemp<10 | intp_sr_vtemp>35) = nan;
    
    %calculate difference
    sr_vtemp_mat(:,i) = intp_sr_vtemp;
    sr_uwnd_mat(:,i)  = intp_sr_uwnd;
    sr_vwnd_mat(:,i)  = intp_sr_vwnd;
    sd_vtemp_mat(:,i) = intp_sd_vtemp;
    sd_uwnd_mat(:,i)  = intp_sd_uwnd;
    sd_vwnd_mat(:,i)  = intp_sd_vwnd;
    
    event_count = event_count+1;
end

%calc mean diff profiles
out = struct;
out.sr_vtemp = sr_vtemp_mat;
out.sd_vtemp = sd_vtemp_mat;
%export wind data struct
out.sr_uwnd = sr_uwnd_mat;
out.sr_vwnd = sr_vwnd_mat;
out.sd_uwnd = sd_uwnd_mat;
out.sd_vwnd = sd_vwnd_mat;
