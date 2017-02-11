function cp_sounding_diurnal_mean
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots the difference afternoon and morning profiles for the one
%location

%% init
%add lib paths
addpath('/home/meso/dev/shared_lib')
addpath('/home/meso/dev/shared_lib/export_fig');
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
load('/home/meso/dev/shared_dataset/arch_sb_days.mat');
sb_datelist = target_days;
load('/home/meso/dev/shared_dataset/arch_nonsb_days.mat');
nonsb_datelist = target_days;


sb_count    = 0;
nonsb_count = 0;

sb_temp_diff = [];
sb_dwpt_diff = [];
sb_uwnd_m    = [];
sb_vwnd_m    = [];
sb_uwnd_a    = [];
sb_vwnd_a    = []; 
sb_dt        = [];
sb_morning_theta_e = [];
sb_afternn_theta_e = [];

for i=1:length(sb_datelist)
    
    morning_early = addtodate(sb_datelist(i),-2,'hour'); %22Z
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
        sb_uwnd_m    = [sb_uwnd_m,morning_intp_data.uwnd];
        sb_vwnd_m    = [sb_vwnd_m,morning_intp_data.vwnd];
        sb_uwnd_a    = [sb_uwnd_a,afternn_intp_data.uwnd];
        sb_vwnd_a    = [sb_vwnd_a,afternn_intp_data.vwnd];
        
        
        morning_theta_e = calc_theta_e(morning_intp_data.temp,morning_intp_data.dwpt,morning_intp_data.pres);
        afternn_theta_e = calc_theta_e(afternn_intp_data.temp,afternn_intp_data.dwpt,afternn_intp_data.pres);
        sb_morning_theta_e = [sb_morning_theta_e,morning_theta_e];
        sb_afternn_theta_e = [sb_afternn_theta_e,afternn_theta_e];
        
        sb_count = sb_count+1;
        sb_dt    = [sb_dt;sb_datelist(i)];
    end

end

nonsb_temp_diff = [];
nonsb_dwpt_diff = [];
nonsb_uwnd_m    = [];
nonsb_vwnd_m    = [];
nonsb_uwnd_a    = [];
nonsb_vwnd_a    = []; 
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
        nonsb_uwnd_m    = [nonsb_uwnd_m,morning_intp_data.uwnd];
        nonsb_vwnd_m    = [nonsb_vwnd_m,morning_intp_data.vwnd];
        nonsb_uwnd_a    = [nonsb_uwnd_a,afternn_intp_data.uwnd];
        nonsb_vwnd_a    = [nonsb_vwnd_a,afternn_intp_data.vwnd];
        
        nonsb_count = nonsb_count+1;
        nonsb_dt    = [nonsb_dt;nonsb_datelist(i)];

    end

end

sb_temp_diff_mean    = nanmean(sb_temp_diff,2);
sb_dwpt_diff_mean    = nanmean(sb_dwpt_diff,2);
nonsb_temp_diff_mean = nanmean(nonsb_temp_diff,2);
nonsb_dwpt_diff_mean = nanmean(nonsb_dwpt_diff,2);

sb_uwnd_m_mean    = nanmean(sb_uwnd_m,2).*2; %double m/s to use 2.5m/s half barb
sb_vwnd_m_mean    = nanmean(sb_vwnd_m,2).*2; %double m/s to use 2.5m/s half barb
sb_uwnd_a_mean    = nanmean(sb_uwnd_a,2).*2; %double m/s to use 2.5m/s half barb
sb_vwnd_a_mean    = nanmean(sb_vwnd_a,2).*2; %double m/s to use 2.5m/s half barb
nonsb_uwnd_m_mean = nanmean(nonsb_uwnd_m,2).*2; %double m/s to use 2.5m/s half barb
nonsb_vwnd_m_mean = nanmean(nonsb_vwnd_m,2).*2; %double m/s to use 2.5m/s half barb
nonsb_uwnd_a_mean = nanmean(nonsb_uwnd_a,2).*2; %double m/s to use 2.5m/s half barb
nonsb_vwnd_a_mean = nanmean(nonsb_vwnd_a,2).*2; %double m/s to use 2.5m/s half barb

%% difference plots

intp_h = afternn_intp_data.h./1000;

hfig = figure('color','w','position',[1 1 600 300])

subplot(1,3,1); hold on; grid on; axis tight
plot(sb_temp_diff_mean,intp_h,'k-','linewidth',3);
%plot(nonsb_temp_diff_mean,intp_h,'k--','linewidth',1.5);
plot([0,0],[0,4],'k-','LineWidth',0.5)
ylabel('Height AMSL (km)','FontSize',14,'FontWeight','demi')
xlabel(['\Delta Temp. (°C)'],'FontSize',14,'FontWeight','demi')
set(gca,'FontSize',12,'xlim',[-4,4],'ylim',[0,4])

subplot(1,3,2); hold on; grid on; axis tight
plot(sb_dwpt_diff_mean,intp_h,'-','Color',[0.5 0.5 0.5],'linewidth',3);
%plot(nonsb_dwpt_diff_mean,intp_h,'--','Color',[0.5 0.5 0.5],'linewidth',1.5);
plot([0,0],[0,4],'k-','LineWidth',0.5)
xlabel(['\Delta DP Temp. (°C)'],'FontSize',14,'FontWeight','demi')
set(gca,'FontSize',12,'xlim',[-4,4],'ylim',[0,4])

subplot(1,3,3); hold on; grid on
set(gca,'FontSize',12,'ylim',[0,4],'xlim',[-1,1],'xtick',[-0.4,0.4],'xticklabels',{'SB','nonSB'})
xlabel(['Wind Barbs (ms^-^1)'],'FontSize',14,'FontWeight','demi')

barb_xscale = ones(length(nonsb_uwnd_m_mean),1).*0.4;
barb_yscale = ones(length(nonsb_uwnd_m_mean),1).*0.4;
barb_x     = zeros(length(nonsb_uwnd_m_mean),1);

%plot(barb_x-0.3,intp_h,':')
%plot(barb_x+0.3,intp_h,':')

for i=1:5:length(nonsb_uwnd_m_mean)
    windbarb(barb_x(i)-0.4,intp_h(i),sb_uwnd_m_mean(i),sb_vwnd_m_mean(i),barb_xscale(i),barb_yscale(i),'LineWidth',0.5,'Color','k');
    windbarb(barb_x(i)-0.4,intp_h(i),sb_uwnd_a_mean(i),sb_vwnd_a_mean(i),barb_xscale(i),barb_yscale(i),'LineWidth',1.5,'Color','k');
    %windbarb(barb_x(i)+0.4,intp_h(i),nonsb_uwnd_m_mean(i),nonsb_vwnd_m_mean(i),barb_xscale(i),barb_yscale(i),'LineWidth',0.5,'Color','k');
    %windbarb(barb_x(i)+0.4,intp_h(i),nonsb_uwnd_a_mean(i),nonsb_vwnd_a_mean(i),barb_xscale(i),barb_yscale(i),'LineWidth',1.5,'Color','k');
end
mkdir('tmp')
mkdir('tmp/img')
export_fig(gcf,'-dpng','-painters','-r300','-nocrop',['tmp/img/ybbn_temp_dwpt_diff_sb.png']);

%% mean theta-e plots

sts_st_list  = {'20141127','20141209','20131124','20140106'};
%sts_st_list  = {'20131124'};
weak_dt_list = {'20141106','20141211','20131113','20141218','20131123','20131229'};
null_dt_list = {'20141217','20131122','20131211','20141031','20141111'};

tmp_indx             = find(ismember(sb_dt,datenum(sts_st_list,'yyyymmdd')));
sts_morning_therta_e = mean(sb_morning_theta_e(:,tmp_indx),2);
sts_afternn_therta_e = mean(sb_afternn_theta_e(:,tmp_indx),2);
sts_afternn_temp     = mean(sb_temp_diff(:,tmp_indx),2);
sts_afternn_dwpt     = mean(sb_dwpt_diff(:,tmp_indx),2);

tmp_indx              = find(ismember(sb_dt,datenum(weak_dt_list,'yyyymmdd')));
weak_morning_therta_e = mean(sb_morning_theta_e(:,tmp_indx),2);
weak_afternn_therta_e = mean(sb_afternn_theta_e(:,tmp_indx),2);

tmp_indx              = find(ismember(sb_dt,datenum(null_dt_list,'yyyymmdd')));
null_morning_therta_e = mean(sb_morning_theta_e(:,tmp_indx),2);
null_afternn_therta_e = mean(sb_afternn_theta_e(:,tmp_indx),2);

% figure; hold on
% plot(sts_morning_therta_e,intp_h,'k-')
% plot(weak_morning_therta_e,intp_h,'k--')
% plot(null_morning_therta_e,intp_h,'k:')
% legend({'sts','weak','null'})
% title('Morning')
% 
% figure; hold on
% plot(sts_afternn_therta_e,intp_h,'k-')
% plot(weak_afternn_therta_e,intp_h,'k--')
% plot(null_afternn_therta_e,intp_h,'k:')
% legend({'sts','weak','null'})
% title('Afternoon')

hfig = figure('color','w','position',[1 1 300 300])
hold on; grid on
h1 = plot(sts_morning_therta_e,intp_h,'-','Color',[0 0 0],'LineWidth',1.5)
h2 = plot(sts_afternn_therta_e,intp_h,'-','Color',[0 0 0],'LineWidth',3)
h3 = plot(weak_morning_therta_e,intp_h,'--','Color',[0.5 0.5 0.5],'LineWidth',1.5)
h4 = plot(weak_afternn_therta_e,intp_h,'--','Color',[0.5 0.5 0.5],'LineWidth',3)
h5 = plot(null_morning_therta_e,intp_h,'-.','Color',[0.8 0.8 0.8],'LineWidth',1.5)
h6 = plot(null_afternn_therta_e,intp_h,'-.','Color',[0.8 0.8 0.8],'LineWidth',3)
legend([h1,h3,h5],{'Convective','Weakening','Null'},'fontsize',10)
ylabel('Height AMSL (km)','FontSize',14,'FontWeight','demi')
xlabel(['\theta','_e (°K)'],'FontSize',14,'FontWeight','demi')
set(gca,'FontSize',12,'xlim',[320,355],'ylim',[0,4])

export_fig(gcf,'-dpng','-painters','-r300','-nocrop',['tmp/img/theta-e_sb.png']);

%% theta-e diff plots

hfig = figure('color','w','position',[1 1 200 300])
hold on; grid on;
h1 = plot(sts_afternn_temp,intp_h,'-','Color','k','LineWidth',1.5)
h2 = plot(sts_afternn_dwpt,intp_h,'-.','Color',[0.5 0.5 0.5],'LineWidth',1.5)
plot([0,0],[0,4],'k-','LineWidth',0.5)
ylabel('Height AMSL (km)','FontSize',14,'FontWeight','demi')
xlabel(['\Delta Temp. (°C)'],'FontSize',14,'FontWeight','demi')
set(gca,'FontSize',12,'xlim',[-4,4],'ylim',[0,4],'xtick',[-4:2:4])

export_fig(gcf,'-dpng','-painters','-r300','-nocrop',['tmp/img/sts_temp_dwpt_diff.png']);

%
