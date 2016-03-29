function cp_plot
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots reprocessed sodar/rass data (use ap-run config file in etc/)
%and UA02D sounding data

%% init
%add lib paths
addpath('../../shared_lib')
addpath('lib')

%read in config
read_config('etc/cp_profile.config','etc/config.mat');
load('etc/config.mat');

%% load/subset data

%load processed mat
load(cp_data_ffn)

%build sr dt list
sr_dt = nan(length(fieldnames(sr_dataset)),1);
for i=1:length(sr_dt)
    sr_dt(i) = sr_dataset.(['data',num2str(i)]).dt;
end

%build snd dt list
snd_dt = nan(length(fieldnames(snd_dataset)),1);
for i=1:length(snd_dt)
    snd_dt(i) = snd_dataset.(['data',num2str(i)]).dt;
end

%find nearest index for snd data
target_dt       = datenum(target_dt_str,'yyyy_mm_dd_HH:MM');
[~,snd_ind]     = min(abs(snd_dt-target_dt));

snd_temp   = snd_dataset.(['data',num2str(snd_ind)]).temp;
snd_dwpt   = snd_dataset.(['data',num2str(snd_ind)]).dwpt;
snd_site_h = snd_dataset.(['data',num2str(snd_ind)]).site_h;
snd_h      = snd_dataset.(['data',num2str(snd_ind)]).h + snd_site_h;
snd_dt     = snd_dataset.(['data',num2str(snd_ind)]).dt;

%calc mean wind speed in direction of rass
sr_target_dt = addtodate(target_dt,1,'hour'); %assume mean sea breeze speed of 25km/h or so (can improve)
[~,sr_ind]  = min(abs(sr_dt-sr_target_dt));

%extract profiles
sr_temp   = sr_dataset.(['data',num2str(sr_ind)]).temp;
sr_dwpt   = sr_dataset.(['data',num2str(sr_ind)]).dwpt;
sr_site_h = sr_dataset.(['data',num2str(sr_ind)]).site_h;
sr_h      = sr_dataset.(['data',num2str(sr_ind)]).h + sr_site_h;
sr_dt     = sr_dataset.(['data',num2str(sr_ind)]).dt;


%% interpolate onto same vertical grid

%create nan mask
sr_nan_mask   = isnan(sr_temp)  | isnan(sr_dwpt);
snd_nan_mask  = isnan(snd_temp) | isnan(snd_dwpt);

%interpolate onto standard height vector
intp_h_vec = [min_h:bin_h:max_h]';
intp_sr_temp  = interp1(sr_h(~sr_nan_mask),sr_temp(~sr_nan_mask),intp_h_vec,'linear',nan);
intp_sr_dwpt  = interp1(sr_h(~sr_nan_mask),sr_dwpt(~sr_nan_mask),intp_h_vec,'linear',nan);
intp_snd_temp = interp1(snd_h(~snd_nan_mask),snd_temp(~snd_nan_mask),intp_h_vec,'linear',nan);
intp_snd_dwpt = interp1(snd_h(~snd_nan_mask),snd_dwpt(~snd_nan_mask),intp_h_vec,'linear',nan);

diff_temp = intp_sr_temp-intp_snd_temp;
diff_dwpt = intp_sr_dwpt-intp_snd_dwpt;

display(['target time:     ',datestr(target_dt)]);
display(['sodar/rass time: ',datestr(sr_dt)]);
display(['sounding time:   ',datestr(snd_dt)]);

close all
figure
subplot(1,2,1)
plot(diff_temp,intp_h_vec)
subplot(1,2,2)
plot(diff_dwpt,intp_h_vec)

keyboard
