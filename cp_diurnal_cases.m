function cp_diurnal_cases
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
figure('color','w','position',[1 1 1000 1000])
%20141106

morning_snd = '20141105-23:00';
afternn_snd = '20141106-04:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,1); hold on
temp_diff = afternn_intp_data.temp - morning_intp_data.temp;
dwpt_diff = afternn_intp_data.dwpt - morning_intp_data.dwpt;
intp_h    = morning_intp_data.h;
plot(temp_diff,intp_h,'r');
plot(dwpt_diff,intp_h,'b');
set(gca,'xlim',[-5,5])
title(afternn_snd)

%20141127

morning_snd = '20141126-23:00';
afternn_snd = '20141127-04:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,2); hold on
temp_diff = afternn_intp_data.temp - morning_intp_data.temp;
dwpt_diff = afternn_intp_data.dwpt - morning_intp_data.dwpt;
intp_h    = morning_intp_data.h;
plot(temp_diff,intp_h,'r');
plot(dwpt_diff,intp_h,'b');
set(gca,'xlim',[-5,5])
title(afternn_snd)

%20141209

morning_snd = '20141208-23:00';
afternn_snd = '20141209-03:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,3); hold on
temp_diff = afternn_intp_data.temp - morning_intp_data.temp;
dwpt_diff = afternn_intp_data.dwpt - morning_intp_data.dwpt;
intp_h    = morning_intp_data.h;
plot(temp_diff,intp_h,'r');
plot(dwpt_diff,intp_h,'b');
set(gca,'xlim',[-5,5])
title(afternn_snd)

%20141211

morning_snd = '20141210-23:00';
afternn_snd = '20141211-04:00';


morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,4); hold on
temp_diff = afternn_intp_data.temp - morning_intp_data.temp;
dwpt_diff = afternn_intp_data.dwpt - morning_intp_data.dwpt;
intp_h    = morning_intp_data.h;
plot(temp_diff,intp_h,'r');
plot(dwpt_diff,intp_h,'b');
set(gca,'xlim',[-5,5])
title(afternn_snd)

%20141217

morning_snd = '20141216-23:00';
afternn_snd = '20141217-03:00';

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,5); hold on
temp_diff = afternn_intp_data.temp - morning_intp_data.temp;
dwpt_diff = afternn_intp_data.dwpt - morning_intp_data.dwpt;
intp_h    = morning_intp_data.h;
plot(temp_diff,intp_h,'r');
plot(dwpt_diff,intp_h,'b');
set(gca,'xlim',[-5,5])
title(afternn_snd)

%20141218

morning_snd = '20141217-23:00';
afternn_snd = '20141218-05:00'; %also 02Z

morning_ind = find(snd_dt_list==datenum(morning_snd,'yyyymmdd-HH:MM'));
afternn_ind = find(snd_dt_list==datenum(afternn_snd,'yyyymmdd-HH:MM'));

morning_intp_data = intp_diurnal_snd(snd_dataset,morning_ind);
afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_ind);

subplot(2,3,6); hold on
temp_diff = afternn_intp_data.temp - morning_intp_data.temp;
dwpt_diff = afternn_intp_data.dwpt - morning_intp_data.dwpt;
intp_h    = morning_intp_data.h;
plot(temp_diff,intp_h,'r');
plot(dwpt_diff,intp_h,'b');
set(gca,'xlim',[-5,5])
title(afternn_snd)



%plot individual day differences or mean in lower 5km? Both dew point and
%temperature

%start with just the 27/11/2014 event

export_fig(gcf,'-dpng','-painters','-r300','-nocrop',['sb_cases.png']);

keyboard

%% Plotting
%create h vec
intp_h_vec = [min_h:bin_h:max_h]';

%plot vtemp
%setup figure
hfig = figure('color','w','position',[1 1 500 600]); hold on; grid on
%plot data
plot(sb_mean_diff_tempv,intp_h_vec,'k-','LineWidth',2)
plot(nonsb_mean_diff_tempv,intp_h_vec,'k--','LineWidth',2)
%plot 0 line
plot(zeros(length(intp_h_vec),1),intp_h_vec,'k')
%add annotations and sizing
xlabel('vtemp diff of SODAR-YBBN (C)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'SB Days','nonSB Days'},'FontSize',12)
set(gca,'FontSize',12,'Xlim',[-1,6])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,num2str(sr_snd_hour_diff),'hr_vtemp_diff_sb.png']);

%plot wspd
sb_sr_wspd     = sqrt(sb_wnd_cmp.sr_uwnd.^2+sb_wnd_cmp.sr_vwnd.^2);
sb_snd_wspd    = sqrt(sb_wnd_cmp.snd_uwnd.^2+sb_wnd_cmp.snd_vwnd.^2);
nonsb_sr_wspd  = sqrt(nonsb_wnd_cmp.sr_uwnd.^2+nonsb_wnd_cmp.sr_vwnd.^2);
nonsb_snd_wspd = sqrt(nonsb_wnd_cmp.snd_uwnd.^2+nonsb_wnd_cmp.snd_vwnd.^2);

sb_wspd_diff    = sb_sr_wspd-sb_snd_wspd;
nonsb_wspd_diff = nonsb_sr_wspd-nonsb_snd_wspd;

%setup figure
hfig = figure('color','w','position',[1 1 500 600]); hold on; grid on
%plot data
plot(sb_wspd_diff,intp_h_vec,'k-','LineWidth',2)
plot(nonsb_wspd_diff,intp_h_vec,'k--','LineWidth',2)
%plot 0 line
plot(zeros(length(intp_h_vec),1),intp_h_vec,'k')
%add annotations and sizing
xlabel('wspd diff of SODAR-YBBN (m/s)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'SB Days','nonSB Days'},'FontSize',12)
set(gca,'FontSize',12,'Xlim',[-5,6])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,num2str(sr_snd_hour_diff),'hr_wspd_diff_sb.png']);
