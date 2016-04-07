function cp_diurnal_mean
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

%create interp_h
close all



%% load/subset data

%load processed mat
load(cp_data_ffn)



%build snd dt list
snd_dt_list = nan(length(fieldnames(snd_dataset)),1);
for i=1:length(snd_dt_list)
    snd_dt_list(i) = snd_dataset.(['data',num2str(i)]).dt_utc;
end

%load sb date list
load('../../shared_datasets/arch_sb_days.mat');
sb_datelist = target_days;
load('../../shared_datasets/arch_nonsb_days.mat');
nonsb_datelist = target_days;


sb_count    = 0;
nonsb_count = 0;

sb_temp_diff = [];
sb_dwpt_diff = [];
sb_uwnd_diff = [];
sb_vwnd_diff = []; 
sb_dt        = [];
for i=1:length(sb_datelist)
    
    morning_early = addtodate(sb_datelist(i)-1,2,'hour'); %22Z
    morning_late  = sb_datelist(i); %00Z
    afternn_early = addtodate(sb_datelist(i),2,'hour'); %02Z
    afternn_late  = addtodate(sb_datelist(i),5,'hour'); %02Z 
    
    morning_idx = find(snd_dt_list>=morning_early & snd_dt_list<=morning_late);
    afternn_idx = find(snd_dt_list>=afternn_early & snd_dt_list<=afternn_late);
    
    if ~isempty(morning_idx) && ~isempty(afternn_idx)
        %select latest morning and afternoon soundings
        morning_idx=morning_idx(end);
        afternn_idx=afternn_idx(end);
        morning_intp_data = intp_diurnal_snd(snd_dataset,morning_idx);
        afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_idx);
        
        sb_temp_diff = [sb_temp_diff,afternn_intp_data.temp-morning_intp_data.temp];
        sb_dwpt_diff = [sb_dwpt_diff,afternn_intp_data.dwpt-morning_intp_data.dwpt];
        sb_uwnd_diff = [sb_uwnd_diff,afternn_intp_data.uwnd-morning_intp_data.uwnd];
        sb_vwnd_diff = [sb_vwnd_diff,afternn_intp_data.vwnd-morning_intp_data.vwnd];
        
        sb_count = sb_count+1;
        sb_dt    = [sb_dt;sb_datelist(i)];
    end

end

nonsb_temp_diff = [];
nonsb_dwpt_diff = [];
nonsb_uwnd_diff = [];
nonsb_vwnd_diff = []; 
nonsb_dt        = [];


for i=1:length(nonsb_datelist)
    
    morning_early = addtodate(nonsb_datelist(i),-2,'hour'); %22Z
    morning_late  = nonsb_datelist(i); %00Z
    afternn_early = addtodate(nonsb_datelist(i),2,'hour'); %02Z
    afternn_late  = addtodate(nonsb_datelist(i),5,'hour'); %02Z 
    
    morning_idx = find(snd_dt_list>=morning_early & snd_dt_list<=morning_late);
    afternn_idx = find(snd_dt_list>=afternn_early & snd_dt_list<=afternn_late);
    
    if ~isempty(morning_idx) && ~isempty(afternn_idx)
        if nonsb_datelist(i)==datenum('20141207','yyyymmdd')
            keyboard
        end
        %select latest morning and afternoon soundings
        morning_idx=morning_idx(end);
        afternn_idx=afternn_idx(end);
        morning_intp_data = intp_diurnal_snd(snd_dataset,morning_idx);
        afternn_intp_data = intp_diurnal_snd(snd_dataset,afternn_idx);
        
        nonsb_temp_diff = [nonsb_temp_diff,afternn_intp_data.temp-morning_intp_data.temp];
        nonsb_dwpt_diff = [nonsb_dwpt_diff,afternn_intp_data.dwpt-morning_intp_data.dwpt];
        nonsb_uwnd_diff = [nonsb_uwnd_diff,afternn_intp_data.uwnd-morning_intp_data.uwnd];
        nonsb_vwnd_diff = [nonsb_vwnd_diff,afternn_intp_data.vwnd-morning_intp_data.vwnd];
        
        nonsb_count = nonsb_count+1;
        nonsb_dt    = [nonsb_dt;nonsb_datelist(i)];

    end

end

sb_temp_diff_std    = nanstd(sb_temp_diff,0,2);
sb_dwpt_diff_std    = nanstd(sb_dwpt_diff,0,2);
nonsb_temp_diff_std = nanstd(nonsb_temp_diff,0,2);
nonsb_dwpt_diff_std = nanstd(nonsb_dwpt_diff,0,2);

sb_temp_diff_mean    = nanmean(sb_temp_diff,2);
sb_dwpt_diff_mean    = nanmean(sb_dwpt_diff,2);
nonsb_temp_diff_mean = nanmean(nonsb_temp_diff,2);
nonsb_dwpt_diff_mean = nanmean(nonsb_dwpt_diff,2);



intp_h = afternn_intp_data.h./1000;

hfig = figure('color','w','position',[1 1 600 300])

subplot(1,2,1); hold on; grid on; axis tight
plot(sb_temp_diff_mean,intp_h,'r','linewidth',2);
plot(nonsb_temp_diff_mean,intp_h,'r--','linewidth',2);
ylabel('Height AMSL (km)','FontSize',14,'FontWeight','demi')
xlabel(['\Delta Temp. ( ','\circ','C)'],'FontSize',14,'FontWeight','demi')
set(gca,'xlim',[-4,4],'ylim',[0,4])

subplot(1,2,2); hold on; grid on; axis tight
plot(sb_dwpt_diff_mean,intp_h,'b','linewidth',2);
plot(nonsb_dwpt_diff_mean,intp_h,'b--','linewidth',2);
xlabel(['\Delta Dew Point Temp. ( ','\circ','C)'],'FontSize',14,'FontWeight','demi')
set(gca,'FontSize',12,'xlim',[-4,4],'ylim',[0,4])

export_fig(gcf,'-dpng','-painters','-r300','-nocrop',['ybbn_temp_dwpt_diff_sb.png']);

keyboard