function cp_mean_sb
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots mean reprocessed sodar/rass data (use ap-run config file in etc/)
%and UA02D sounding data for sea/nonsb days

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

%build sr dt list
sr_dt_list = nan(length(fieldnames(sr_dataset)),1);
for i=1:length(sr_dt_list)
    sr_dt_list(i) = sr_dataset.(['data',num2str(i)]).dt_local;
end

%build sd dt list
sd_dt_list = nan(length(fieldnames(snd_dataset)),1);
for i=1:length(sd_dt_list)
    sd_dt_list(i) = snd_dataset.(['data',num2str(i)]).dt_utc;
end
%convert to local time
for i=1:length(sd_dt_list)
    sd_dt_list(i) = addtodate(sd_dt_list(i),utc_offset,'hour');
end


%build common sd sr date list
sd_sr_datelist = intersect(unique(floor(sr_dt_list)),unique(floor(sd_dt_list)));

%load sb date list
load('../../shared_datasets/arch_sb_days.mat');
sb_datelist = target_days;
load('../../shared_datasets/arch_nonsb_days.mat');
nsb_datelist = target_days;

%build common sd sr sb date list
sb_sr_datelist  = intersect(sr_dt_list,sb_datelist);
nsb_sr_datelist = intersect(sr_dt_list,nsb_datelist);


%extract morning time data
target_time     = 9;
[mn_sb_data,~]  = process_sr_profile(sb_sr_datelist,sr_dt_list,target_time);
[mn_nsb_data,~] = process_sr_profile(nsb_sr_datelist,sr_dt_list,target_time);
target_time     = 15;
[an_sb_data,~]  = process_sr_profile(sb_sr_datelist,sr_dt_list,target_time);
[an_nsb_data,~] = process_sr_profile(nsb_sr_datelist,sr_dt_list,target_time);


sb_sr_vtemp_diff  = an_sb_data.sr_vtemp  - mn_sb_data.sr_vtemp;
nsb_sr_vtemp_diff = an_nsb_data.sr_vtemp - mn_nsb_data.sr_vtemp;
sb_sr_wspd_diff   = an_sb_data.sr_wspd  - mn_sb_data.sr_wspd;
nsb_sr_wspd_diff  = an_nsb_data.sr_wspd - mn_nsb_data.sr_wspd;

%calc vtemp diffs
sb_sr_vtemp_diff_mean  = nanmean(sb_sr_vtemp_diff,2);
nsb_sr_vtemp_diff_mean = nanmean(nsb_sr_vtemp_diff,2);
sb_sr_wspd_diff_mean   = nanmean(sb_sr_wspd_diff,2);
nsb_sr_wspd_diff_mean  = nanmean(nsb_sr_wspd_diff,2);

%% Plotting
%create h vec
intp_h_vec = [min_h:bin_h:max_h]';
hfig = figure('color','w','position',[1 1 600 300]); hold on; grid on
%plot vtemp
%setup figure
%plot data
subplot(1,2,1); axis tight; hold on; grid on
plot(sb_sr_vtemp_diff_mean,intp_h_vec,'k-','LineWidth',2)
plot(nsb_sr_vtemp_diff_mean,intp_h_vec,'k--','LineWidth',2)
%add annotations and sizing
xlabel(['\Delta Virtual Temp. ( ','\circ','C)'],'FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
%legend({'SB diff','nSB diff'},'FontSize',12)
set(gca,'FontSize',12,'Xlim',[0,5],'Ylim',[min_h,400])
%plot wspd

%setup figure
subplot(1,2,2); axis tight; hold on; grid on
%plot data
plot(sb_sr_wspd_diff_mean,intp_h_vec,'k-','LineWidth',2)
plot(nsb_sr_wspd_diff_mean,intp_h_vec,'k--','LineWidth',2)
%add annotations and sizing
xlabel('\Delta Wind Speed (m/s)','FontSize',14,'FontWeight','demi')
%legend({'SB SR','nSB SR'},'FontSize',12)
set(gca,'FontSize',12,'Xlim',[0,5],'Ylim',[min_h,400])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop','sr_vtemp_wspd_diff_sb_nsb.png');
