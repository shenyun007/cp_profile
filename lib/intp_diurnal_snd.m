function intp_data = intp_diurnal_snd(snd_dataset,snd_idx)
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%% init
%add lib paths
addpath('/home/meso/dev/shared_lib')
addpath('/home/meso/dev/shared_lib/export_fig');
addpath('lib')

%read in config
load('etc/config.mat');

%load datasets

snd_h    = snd_dataset.(['data',num2str(snd_idx)]).h;
snd_temp = snd_dataset.(['data',num2str(snd_idx)]).temp;
snd_dwpt = snd_dataset.(['data',num2str(snd_idx)]).dwpt;
snd_pres = snd_dataset.(['data',num2str(snd_idx)]).pres;
snd_wspd = snd_dataset.(['data',num2str(snd_idx)]).wspd;
snd_wdir = snd_dataset.(['data',num2str(snd_idx)]).wdir;

%calc sounding u winds
snd_wnd_nan_mask           = isnan(snd_wdir) | isnan(snd_wspd);
snd_wdir(snd_wnd_nan_mask) = 0;
snd_wspd(snd_wnd_nan_mask) = 0;
[snd_uwnd,snd_vwnd] = compass2cart(snd_wdir,snd_wspd);
snd_uwnd(snd_wnd_nan_mask) = nan;
snd_vwnd(snd_wnd_nan_mask) = nan;

%interp
snd_thermo_mask  = isnan(snd_temp) | isnan(snd_dwpt);
snd_wnd_mask     = isnan(snd_uwnd) | isnan(snd_vwnd);
intp_h_vec = [min_h_diurnal:bin_h_diurnal:max_h_diurnal]';

intp_data = struct;

intp_data.h         = intp_h_vec;
intp_data.temp  = interp1(snd_h(~snd_thermo_mask),snd_temp(~snd_thermo_mask),intp_h_vec,'linear',nan);
intp_data.dwpt  = interp1(snd_h(~snd_thermo_mask),snd_dwpt(~snd_thermo_mask),intp_h_vec,'linear',nan);
intp_data.uwnd  = interp1(snd_h(~snd_wnd_mask),snd_uwnd(~snd_wnd_mask),intp_h_vec,'linear',nan);
intp_data.vwnd  = interp1(snd_h(~snd_wnd_mask),snd_vwnd(~snd_wnd_mask),intp_h_vec,'linear',nan);
intp_data.pres  = interp1(snd_h(~snd_wnd_mask),snd_pres(~snd_wnd_mask),intp_h_vec,'linear',nan);

