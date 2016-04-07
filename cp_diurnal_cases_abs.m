function cp_diurnal_cases_abs
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots the difference afternoon and morning profiles for the one
%location

%% init
%add lib paths
addpath('../../shared_lib')
addpath('../../shared_lib/export_fig');
addpath('lib')

%read in config
read_config('etc/cp_profile.config','etc/config.mat');
load('etc/config.mat');

close all

%% load/subset data

%load processed mat
load(cp_data_ffn)

%build snd dt list
snd_dt_list = nan(length(fieldnames(snd_dataset)),1);
for i=1:length(snd_dt_list)
    snd_dt_list(i) = snd_dataset.(['data',num2str(i)]).dt_utc;
end

%% plot
figure('color','w','position',[1 1 1500 1000])
%20141106

morning_snd = '20141105-23:00';
afternn_snd = '20141106-04:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,1); hold on
intp_h    = morning_intp_data.h;
plot(afternn_intp_data.temp,intp_h,'r','linewidth',2);
plot(afternn_intp_data.dwpt,intp_h,'b','linewidth',2);
plot(morning_intp_data.temp,intp_h,'r');
plot(morning_intp_data.dwpt,intp_h,'b');
set(gca,'ylim',[0 3000])
title(afternn_snd)

%20141127

morning_snd = '20141126-23:00';
afternn_snd = '20141127-04:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,2); hold on
intp_h    = morning_intp_data.h;
plot(afternn_intp_data.temp,intp_h,'r','linewidth',2);
plot(afternn_intp_data.dwpt,intp_h,'b','linewidth',2);
plot(morning_intp_data.temp,intp_h,'r');
plot(morning_intp_data.dwpt,intp_h,'b');
set(gca,'ylim',[0 3000])
title(afternn_snd)

%20141209

morning_snd = '20141208-23:00';
afternn_snd = '20141209-03:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,3); hold on
intp_h    = morning_intp_data.h;
plot(afternn_intp_data.temp,intp_h,'r','linewidth',2);
plot(afternn_intp_data.dwpt,intp_h,'b','linewidth',2);
plot(morning_intp_data.temp,intp_h,'r');
plot(morning_intp_data.dwpt,intp_h,'b');
set(gca,'ylim',[0 3000])
title(afternn_snd)

%20141211

morning_snd = '20141210-23:00';
afternn_snd = '20141211-04:00';


morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,4); hold on
intp_h    = morning_intp_data.h;
plot(afternn_intp_data.temp,intp_h,'r','linewidth',2);
plot(afternn_intp_data.dwpt,intp_h,'b','linewidth',2);
plot(morning_intp_data.temp,intp_h,'r');
plot(morning_intp_data.dwpt,intp_h,'b');
set(gca,'ylim',[0 3000])
title(afternn_snd)

%20141217

morning_snd = '20141216-23:00';
afternn_snd = '20141217-03:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,5); hold on
intp_h    = morning_intp_data.h;
plot(afternn_intp_data.temp,intp_h,'r','linewidth',2);
plot(afternn_intp_data.dwpt,intp_h,'b','linewidth',2);
plot(morning_intp_data.temp,intp_h,'r');
plot(morning_intp_data.dwpt,intp_h,'b');
set(gca,'ylim',[0 3000])
title(afternn_snd)

%20141218

morning_snd = '20141217-23:00';
afternn_snd = '20141218-05:00'; %also 02Z

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,6); hold on
intp_h    = morning_intp_data.h;
plot(afternn_intp_data.temp,intp_h,'r','linewidth',2);
plot(afternn_intp_data.dwpt,intp_h,'b','linewidth',2);
plot(morning_intp_data.temp,intp_h,'r');
plot(morning_intp_data.dwpt,intp_h,'b');
set(gca,'ylim',[0 3000])
title(afternn_snd)



%plot individual day differences or mean in lower 5km? Both dew point and
%temperature

%start with just the 27/11/2014 event

export_fig(gcf,'-dpng','-painters','-r300','-nocrop',['sb_cases_abs.png']);

keyboard